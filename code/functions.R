## Propensity Score Caliper Matching
library(MASS)

# Function for computing 
# rank based Mahalanobis distance.  Prevents an outlier from
# inflating the variance for a variable, thereby decreasing its importance.
# Also, the variances are not permitted to decrease as ties 
# become more common, so that, for example, it is not more important
# to match on a rare binary variable than on a common binary variable
# z is a vector, length(z)=n, with z=1 for treated, z=0 for control
# X is a matrix with n rows containing variables in the distance

smahal=
  function(z,X){
    X<-as.matrix(X)
    n<-dim(X)[1]
    rownames(X)<-1:n
    k<-dim(X)[2]
    m<-sum(z)
    for (j in 1:k) X[,j]<-rank(X[,j])
    cv<-cov(X)
    vuntied<-var(1:n)
    rat<-sqrt(vuntied/diag(cv))
    cv<-diag(rat)%*%cv%*%diag(rat)
    out<-matrix(NA,m,n-m)
    Xc<-X[z==0,]
    Xt<-X[z==1,]
    rownames(out)<-rownames(X)[z==1]
    colnames(out)<-rownames(X)[z==0]
    library(MASS)
    icov<-ginv(cv)
    for (i in 1:m) out[i,]<-mahalanobis(Xc,Xt[i,],icov,inverted=T)
    out
  }

# Function for adding a propensity score caliper to a distance matrix dmat
# calipersd is the caliper in terms of standard deviation of the logit propensity scoe
addcaliper=function(dmat,z,logitp,calipersd=.2,penalty=1000){
  sd.logitp=sd(logitp)
  adif=abs(outer(logitp[z==1],logitp[z==0],"-"))
  adif=(adif-(calipersd*sd.logitp))*(adif>(calipersd*sd.logitp))
  dmat=dmat+adif*penalty
  dmat
}


# Need to redefine crossmatchtest to reflect update in nbpMatching library
crossmatchtest=function(z,D){
  # crossmatch test
  # z is binary vector indicating the group
  # D is a distance matrix of covariates
  
  plainmatrix<-as.matrix(10000*max(1/min(D[D>0]),1)*D)
  diag(plainmatrix) <- 0
  mdm<-distancematrix(plainmatrix)
  res<-nonbimatch(mdm)
  
  mt<-pmin(as.numeric(res$matches$Group1.Row),as.numeric(res$matches$Group2.Row))
  z0<-z[mt>0]
  mt0<-factor(mt[mt>0])
  tab<-table(factor(z0),mt0)
  a1<-sum(tab[1,]==1)
  bigN<-length(z0)
  n<-sum(z0)
  if (bigN<340){ 
    dist<-crossmatchdist(bigN,n)
    pval<-dist[5,dist[2,]==a1]
  }
  else{
    pval<-NA
  }
  m<-bigN-n
  Ea1<-(n*m/(bigN-1))
  Va1<-2*n*(n-1)*m*(m-1)/((bigN-3)*(bigN-1)*(bigN-1))
  dev<-(a1-Ea1)/sqrt(Va1)
  approx<-pnorm(dev)
  list(a1=a1,Ea1=Ea1,Va1=Va1,dev=dev,pval=pval,approxpval=approx)
}

# Function for computing rank-based Mahalanobis distance among all units
smahal.all=
  function(X){
    X<-as.matrix(X)
    n<-dim(X)[1]
    rownames(X)<-1:n
    k<-dim(X)[2]
    for (j in 1:k) X[,j]<-rank(X[,j])
    cv<-cov(X)
    vuntied<-var(1:n)
    rat<-sqrt(vuntied/diag(cv))
    cv<-diag(rat)%*%cv%*%diag(rat)
    library(MASS)
    icov<-ginv(cv)
    out<-matrix(NA,n,n)
    for (i in 1:n) out[i,]<-mahalanobis(X,X[i,],icov,inverted=T)
    out
  }






alignedranktest=function(outcome,matchedset,treatment,alternative="two.sided"){
  # Remove units that are not matched
  outcome=outcome[matchedset>0];
  treatment=treatment[matchedset>0];
  matchedset=matchedset[matchedset>0];
  # Compute means in each matched set
  matchedset.mean=tapply(outcome,matchedset,mean);
  # Compute residuals
  matchedset.mean.expand=matchedset.mean[matchedset];
  resids=outcome-matchedset.mean.expand;
  # Rank the residuals
  rankresids=rank(resids);
  # Test statistics = Sum of residuals in treatment group
  teststat=sum(rankresids[treatment==1]);
  # Expected value and variance of test statistic
  mean.matchedset.rankresids=tapply(rankresids,matchedset,mean);
  notreated.matchedset=tapply(treatment,matchedset,sum);
  nocontrol.matchedset=tapply(1-treatment,matchedset,sum);
  no.matchedset=notreated.matchedset+nocontrol.matchedset;
  ev.teststat=sum(mean.matchedset.rankresids*notreated.matchedset);
  mean.matchedset.rankresids.expand=mean.matchedset.rankresids[matchedset];
  rankresids.resid.squared=(rankresids-mean.matchedset.rankresids.expand)^2; 
  squared.resids.sum=tapply(rankresids.resid.squared,matchedset,sum);
  var.teststat=sum(((notreated.matchedset*nocontrol.matchedset)/(no.matchedset*(no.matchedset-1)))*squared.resids.sum);
  
  if(alternative=="two.sided"){
    pval=2*pnorm(-abs((teststat-ev.teststat)/sqrt(var.teststat)));
  }
  if(alternative=="greater"){
    pval=1-pnorm((teststat-ev.teststat)/sqrt(var.teststat));
  }
  if(alternative=="less"){
    pval=pnorm((teststat-ev.teststat)/sqrt(var.teststat));
  }
  pval;
}

# Calculate standardized difference before and after a full match
# Drop observations with missing values from the calculations
# stratum.myindex should contain strata for each subject with numbers 1:I (=
# number of strata), 0 means a unit was not matched
standardized.diff.func=function(x,treatment,stratum.myindex,missing=rep(0,length(x))){
  xtreated=x[treatment==1 & missing==0];
  xcontrol=x[treatment==0 & missing==0];
  var.xtreated=var(xtreated);
  var.xcontrol=var(xcontrol);
  combinedsd=sqrt(.5*(var.xtreated+var.xcontrol));
  std.diff.before.matching=(mean(xtreated)-mean(xcontrol))/combinedsd;
  nostratum=length(unique(stratum.myindex))-1*min(stratum.myindex==0);
  diff.in.stratum=rep(0,nostratum);
  treated.in.stratum=rep(0,nostratum);
  for(i in 1:nostratum){
    diff.in.stratum[i]=mean(x[stratum.myindex==i & treatment==1 & missing==0])-mean(x[stratum.myindex==i & treatment==0 & missing==0]);
    treated.in.stratum[i]=sum(stratum.myindex==i & treatment==1 & missing==0);
    if(sum(stratum.myindex==i & treatment==0 & missing==0)==0){
      treated.in.stratum[i]=0;
      diff.in.stratum[i]=0;
    }
  }
  std.diff.after.matching=(sum(treated.in.stratum*diff.in.stratum)/sum(treated.in.stratum))/combinedsd;
  list(std.diff.before.matching=std.diff.before.matching,std.diff.after.matching=std.diff.after.matching);
}


