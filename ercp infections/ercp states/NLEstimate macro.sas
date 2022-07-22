/****************************************************************/
/*                                                              */
/*    NAME: NLEstimate                                          */
/*   TITLE: Estimating nonlinear functions of model parameters  */
/* PRODUCT: STAT                                                */
/*  SYSTEM: ALL                                                 */
/*    KEYS: contrast estimate nonlinear                         */
/*   PROCS: NLMIXED                                             */
/*    DATA:                                                     */
/* SUPPORT: schlotz                     UPDATE:  4Jun2018       */
/*     REF:                                                     */
/*    MISC: The following SAS products are required to run      */
/*          this macro: BASE, STAT                              */
/*                                                              */
/****************************************************************/

/*----------------------------------------------------------------------

The NLEstimate macro allows you to estimate one or more linear or nonlinear
combinations of parameters from any model for which you can save the model
parameters and their variance-covariance matrix. Most modeling procedures which
offer ESTIMATE, CONTRAST, or LSMEANS statements only provide for estimating or
testing linear combinations of model parameters. However, common estimation
problems often involve nonlinear combinations, particularly in generalized
models with nonidentity link functions such as logistic and Poisson models.

The NLEstimate macro always attempts to check for a later version of itself. If
it is unable to do this (such as if there is no active internet connection
available), the macro will issue the following message in the log:

   NOTE: Unable to check for newer version
   
The computations performed by the macro are not affected by the appearance of
this message.

The NLEstimate macro takes advantage of the ESTIMATE statement in PROC NLMIXED
which can estimate nonlinear functions of model parameters. It uses NLMIXED to
fit a multivariate normal distribution with mean equal to the input model
parameter estimates and variance equal to the input model covariance matrix.
This creates a log likelihood that is zero and NLMIXED is able to converge
immediately to a model with the specified parameter estimates and covariance
matrix. It is then possible to estimate the functions specified in the F= or
FDATA= parameters.

Some modeling procedures cannot provide the necessary covariance matrix for
some models or estimands. For example, since PROC GLIMMIX cannot provide a
covariance matrix that includes the scale parameter, an estimand involving the
scale parameter cannot be estimated. Some procedures either do not have a STORE
statement (such as PROC FMM) or do not save the necessary model information
(such as PROC COUNTREG). In such cases, use INEST= and INCOVB= instead of
INSTORE=. Note that in some cases, such as with PROC FMM, the data set
containing the covariance matrix must be modified to remove extraneous numeric
variables in order to avoid a compatibility error.

There are two basic uses of the macro:

1) Display parameter names. Specify SHOWNAMES as the first argument to display
a list of the model parameter estimates and their associated names. The
parameter names are needed to write the functions to be estimated (estimands)
in a subsequent run of the macro. The F= and FDATA= parameters can be omitted
when using SHOWNAMES. For example:

   %NLEstimate(shownames, instore=logmod)

2) Estimation of functions. Input the saved model using INSTORE= (preferred) or
both of INEST= and INCOVB=. Then specify the estimand(s) using either the F= or
FDATA= parameter (or both). Do not specify SHOWNAMES. The macro again displays
the parameter names (unless LISTNAMES=NO is specified) and also displays 
estimates of the specified functions. For example:

   %NLEstimate(instore=logmod, fdata=funcs)

The arguments available with the NLEstimate macro are discussed below. The
necessary model information is provided to the macro by specifying either the
INSTORE= parameter or both the INEST= and INCOVB= arguments. If the modeling
procedure provides a STORE statement for saving the fitted model, INSTORE= is
generally the better method for providing the model information. Additionally,
if SHOWNAMES is not specified as the first argument, either the FDATA= or F=
arguments (or both) is required.

------------------------------------------------------------------------

EXAMPLE: Estimate difference in group means in a log-linked gamma model

Using data from the example titled "Gamma Distribution Applied to Life Data" in
the GENMOD documentation, these statements fit the log-linked gamma model and
save the model in an item store.

      proc genmod data = lifdat;
         class mfg;
         model lifetime = mfg / dist=gamma link=log;
         store out=gammod;
         run;

This call of the NLEstimate macro displays the model parameter names for use in
the F= or FDATA= arguments of the macro.

      %NLEstimate(shownames, instore=gammod) 

The mean difference in MFG levels A and B is this nonlinear combination of
parameters

      mean(A) - mean(B) = exp(Intercept+MFGA) - exp(Intercept)

and is estimated by this call of the NLEstimate macro

      %NLEstimate(instore=gammod, label=Mean Diff, f=exp(B_p1+B_p2)-exp(B_p1))

This call of the NLEstimate macro estimates the individual MFG level means as
well as the difference in means

      data fd; 
         length label f $32767; 
         infile datalines delimiter=',';
         input label f; 
         datalines;
      Mfg A,exp(B_p1+B_p2)
      Mfg B,exp(B_p1)
      Mean Diff,exp(B_p1+B_p2)-exp(B_p1)
      ;
      %NLEstimate(instore=gammod, fdata=fd)


ADDITIONAL EXAMPLES AVAILABLE AT support.sas.com:

Estimating differences in probabilities with confidence interval
   http://support.sas.com/kb/37228.html
   
Estimating sensitivity, specificity, positive and negative predictive values,
and other statistics
   http://support.sas.com/kb/24170.html
   
Estimating rate differences (with confidence interval) using a Poisson model
   http://support.sas.com/kb/37344.html
   
Estimating relative risks in a multinomial response model
   http://support.sas.com/kb/57798.html
   
Confidence interval for a ratio of two linear combinations of model parameters
   http://support.sas.com/kb/56476.html
   
Comparing groups with respect to the dose (or predictor value) that yields a
specified response probability
   http://support.sas.com/kb/44931.html
   
Harmonic mean estimate, confidence interval, and test for lognormal data
   http://support.sas.com/kb/44415.html
   
Estimating and comparing counts and rates (with confidence intervals) in zero-
inflated models
   http://support.sas.com/kb/44354.html
   
Estimating a relative risk (also called risk ratio, prevalence ratio)
   http://support.sas.com/kb/23003.html
   
Fitting truncated Poisson and negative binomial models
   http://support.sas.com/kb/43522.html
   
Estimating the difference in differences of means
   http://support.sas.com/kb/61830.html

------------------------------------------------------------------------

DISCLAIMER:

       THIS INFORMATION IS PROVIDED BY SAS INSTITUTE INC. AS A SERVICE
TO ITS USERS.  IT IS PROVIDED "AS IS".  THERE ARE NO WARRANTIES,
EXPRESSED OR IMPLIED, AS TO MERCHANTABILITY OR FITNESS FOR A
PARTICULAR PURPOSE REGARDING THE ACCURACY OF THE MATERIALS OR CODE
CONTAINED HEREIN.

----------------------------------------------------------------------*/

%*===================== Macro Argument List Start =====================;

%macro NLEstimate(  
version,        /* Any specified text as first argument displays the  */
                /* current version of the NLEstimate macro. Specify   */
                /* SHOWNAMES to display only a list of the model      */
                /* parameter estimates and their associated names (no */
                /* estimation is done). SHOWNAMES is ignored if       */
                /* SCORE= is specified or if LISTNAMES=NO.            */
instore=,       /* Specifies the item store that was saved using      */
                /* the STORE statement in the modeling procedure. The */
                /* OUT= option in the STORE statement saves the model */
                /* in a file known as an item store. This is the      */
                /* preferred method for providing the required model  */
                /* information. However, if the modeling procedure    */
                /* does not offer the STORE statement, then you may   */
                /* be able to use the INEST= and INCOVB= arguments.   */
inest=,         /* Specifies the data set of parameter estimates      */
                /* saved using an ODS OUTPUT statement in the         */
                /* modeling procedure. The parameter estimates of the */
                /* model should be stored in a variable named         */
                /* ESTIMATE in this data set. An error is issued if   */
                /* the ESTIMATE variable is not found.                */
incovb=,        /* Specifies the data set containing the variance-    */
                /* covariance matrix of model parameters saved using  */
                /* an ODS OUTPUT statement in the modeling procedure. */
                /* Typically, an option such as COVB is required in   */
                /* the modeling procedure to make this matrix         */
                /* available for saving. If the saved data set        */
                /* contains numeric variables other than those        */
                /* containing the covariance matrix, they should be   */
                /* removed before specifying the data set in this     */
                /* macro argument in order to avoid a compatibility   */
                /* error. The INCOVB= data set should have the same   */
                /* number of observations (rows) and variables        */
                /* (columns) as the number of rows in the INEST= data */
                /* set in order to be compatible.                     */
f=,             /* Specifies an expression representing a single      */
                /* function to be estimated (the estimand) involving  */
                /* the parameter names. This argument can be used     */
                /* when only one function is to be estimated. Do not  */
                /* use double quotes (") in the expression. Use       */
                /* single quotes (') instead if needed. Any quotes    */
                /* must appear in pairs. For estimands that involve   */
                /* values from data set variables, also use the       */
                /* SCORE= argument. When SCORE= is not specified, the */
                /* displayed results are also saved in data set Est.  */
fdata=,         /* Specifies a data set containing the functions to   */
                /* be estimated (estimands). This argument can be     */
                /* used when you have more than one function to       */
                /* estimate. This data set must contain two character */
                /* variables with names LABEL and F. In each observa- */
                /* tion of the data set, F contains an expression to  */
                /* be estimated involving the parameter names of the  */
                /* model. LABEL contains a text string used to label  */
                /* the estimate of the function in the results. The   */
                /* label does not need to be enclosed in quotes. Do   */
                /* not use double quotes (") in the either the F or   */
                /* LABEL variable. Use single quotes (') instead if   */ 
                /* needed. The displayed results are also saved in    */
                /* data set Est.                                      */
label=,         /* Specifies optional text to label the single        */
                /* function specified in the F= argument. Ignored if  */
                /* F= is not specified. Do not use quotes surrounding */
                /* or within the specified text.                      */
score=,         /* Specifies a data set for which the function in F=  */
                /* is evaluated for each observation. Use this        */
                /* parameter along with the F= parameter when the     */
                /* estimand involves values of variables in the input */
                /* data set. The SCORE= parameter cannot be used with */
                /* the FDATA= parameter.                              */
outscore=NLEst, /* Names a data set to be created that is a copy of   */
                /* the SCORE= data set and has additional variables   */
                /* for the estimated function, its standard error,    */
                /* test statistic, p-value, and confidence limits in  */
                /* each observation. If not specified, the data set   */
                /* is named NLEst. No data set is created if SCORE=   */
                /* is not specified.                                  */
df=,            /* Specifies the degrees of freedom to be used in the */
                /* test and confidence interval computed for the      */
                /* estimated function(s). If omitted, large-sample    */
                /* Wald statistics are given. The degrees of freedom  */
                /* for testing a linear combination of parameters in  */
                /* a linear model would typically be the number of    */
                /* observations used in fitting the model minus the   */
                /* number of parameters estimated in the model –      */
                /* essentially, the error degrees of freedom.         */
alpha=0.05,     /* Specifies the alpha level, between 0 and 1, to be  */
                /* used in computing confidence limits. If omitted,   */
                /* ALPHA=0.05.                                        */
listnames=yes,  /* Display parameter names before the results table.  */
                /* LISTNAMES=NO suppresses the table of names.        */
title=          /* Title for results. Title must not contain quotes   */
                /* (" or '), ampersands(&), commas(,), or parentheses.*/
                /* If omitted, title is Nonlinear Function Estimate.  */
);

;*=========================== Macro Start =============================;

   %local notesopt; 
   %let notesopt = %sysfunc(getoption(notes));
   %let time = %sysfunc(datetime());
   %let _version=1.51;
   %let status=ok;
   %let PInit =;
   %let nrecdiv = 300;
   %let Expnt=;
   %let Expnt1=;
   %if %index(%upcase(&version),DEBUG) %then %do;
     options notes mprint
       %if %index(%upcase(&version),DEBUG2) %then mlogic symbolgen;
     ;  
     ods select all;
     %put _user_;
   %end;
   %else %do;
     options nonotes nomprint nomlogic nosymbolgen;
     ods exclude all;
   %end;

   /* 
   /  Check for newer version. 
   /------------------------------------------------------------------
   %let _notfound=0;
   filename _ver url 'http://ftp.sas.com/techsup/download/stat/versions.dat' 
	    termstr=crlf;
   data _null_;
     infile _ver end=_eof;
     input name:$15. ver;
     if upcase(name)="&sysmacroname" then do;
       call symput("_newver",ver); stop;
     end;
     if _eof then call symput("_notfound",1);
     run;
   options notes;
   %if &version ne %then %put NOTE: &sysmacroname macro Version &_version..;
   %if &syserr ne 0 or &_notfound=1 %then
     %put NOTE: Unable to check for newer version of &sysmacroname macro.;
   %else %if %sysevalf(&_newver > &_version) %then %do;
     %put NOTE: A newer version of the &sysmacroname macro is available at;
     %put NOTE- this location: http://support.sas.com/ ;
   %end;
   %if %index(%upcase(&version),DEBUG)=0 %then options nonotes;;
	*/

   /*
   /  Input checking.
   /------------------------------------------------------------------*/
   %if (&instore= and &inest= and &incovb=) or
       (&instore ne and (&inest ne or &incovb ne)) %then %do;
     %put ERROR: Either INSTORE= or both INEST= and INCOVB= must be specified.;
     %let status=input_err;
     %goto exit;
   %end;
   %if (&inest ne and &incovb=) or (&inest= and &incovb ne) %then %do;
     %put ERROR: Both INEST= and INCOVB= must be specified.;
     %let status=input_err;
     %goto exit;
   %end;
   %if %index(&f,%str(%"))>0 or %index(&label,%str(%"))>0 %then %do;
     %put ERROR: Do not use double quotes (%str(%")) in F= or LABEL=.;
     %put ERROR- Use single quotes (%str(%')).;
     %let status=input_err;
     %goto exit;
   %end;
   %if %index(%quote(&title),%str(%")) or %index(%quote(&title),%str(%')) %then %do;
     %put ERROR: Do not use quotes (%str(%") or %str(%')) in TITLE=.;
     %let status=input_err;
     %goto exit;
   %end;
   %if %index(%upcase(&version),SHOWNAMES)=0 and &fdata= and %quote(&f)= %then %do;
     %put ERROR: Either or both of FDATA= and F= must be specified.;
     %let status=input_err;
     %goto exit;
   %end;
   %if &inest ne %then %do;
     %if %sysfunc(exist(&inest)) ne 1 %then %do;
       %put ERROR: INEST= data set not found.;
       %let status=input_err;
       %goto exit;
     %end;
     %else %do;
       %let dsid=%sysfunc(open(&inest));
       %if &dsid %then %do;
         %if %sysfunc(varnum(&dsid,estimate))=0 %then %do;
           %put ERROR: Required variable, ESTIMATE, not found.;
           %let status=input_err;
         %end;
         %let rc=%sysfunc(close(&dsid));
         %if &status=input_err %then %goto exit;
       %end;
       %else %do;
         %put ERROR: Could not open INEST= data set.;
         %goto exit;
       %end;
     %end;
   %end;
   %if &incovb ne and %sysfunc(exist(&incovb)) ne 1 %then %do;
     %put ERROR: INCOVB= data set not found.;
     %let status=input_err;
     %goto exit;
   %end;
   %if &score ne and %sysfunc(exist(&score)) ne 1 %then %do;
     %put ERROR: SCORE= data set not found.;
     %let status=input_err;
     %goto exit;
   %end;
   %if &score ne and &fdata ne %then %do;
     %put ERROR: When SCORE= is specified FDATA= is not allowed. Specify F=.;
     %let status=input_err;
     %goto exit;
   %end;
   %if &score ne and %quote(&f)= %then %do;
     %put ERROR: When SCORE= is specified F= must also be specified.;
     %let status=input_err;
     %goto exit;
   %end;
   %if &instore ne and %sysfunc(exist(&instore,ITEMSTOR)) ne 1 %then %do;
     %put ERROR: INSTORE= item store not found.;
     %let status=input_err;
     %goto exit;
   %end;
   %if &fdata ne %then %do;
     %if %sysfunc(exist(&fdata)) ne 1 %then %do;
       %put ERROR: FDATA= data set not found.;
       %let status=input_err;
       %goto exit;
     %end;
     %else %do;
       %let dsid=%sysfunc(open(&fdata));
       %if &dsid %then %do;
         %if %sysfunc(varnum(&dsid,label))=0 %then %do;
           %put ERROR: Required variable, LABEL, not found.;
           %let status=input_err;
         %end;
         %if %sysfunc(varnum(&dsid,f))=0 %then %do;
           %put ERROR: Required variable, F, not found.;
           %let status=input_err;
         %end;
         %let rc=%sysfunc(close(&dsid));
         %if &status=input_err %then %goto exit;
       %end;
       %else %do;
         %put ERROR: Could not open FDATA= data set.;
         %goto exit;
       %end;
     %end;
   %end;
   %let listnames=%upcase(%substr(&listnames,1,1));
   %if &listnames ne Y and &listnames ne N %then %do;
     %put ERROR: The LISTNAMES= value must be either YES or NO.;
     %goto exit;
   %end;
   %if %sysevalf(&df ne) %then 
     %if %sysevalf(%sysfunc(mod(&df,1)) ne 0 or &df<=0) %then %do;
       %put ERROR: The DF= value must be an integer value greater than zero.;
       %goto exit;
     %end;
   %if %sysevalf(&alpha<=0 or &alpha>=1) %then %do;
     %put ERROR: The ALPHA= value must be between 0 and 1.;
     %goto exit;
   %end;

   /*
   /  Put parameter estimates and covariance matrics into data sets.
   /------------------------------------------------------------------*/
   %if &instore ne %then %do;
     proc plm restore=&instore;
        show parameters covariance;
        ods output ParameterEstimates=_Parm
                   Cov               =_Cov;
     run;
     %if &syserr %then %do;
       %let status=plm_err;
       %goto exit;
     %end;
     data _cov; set _cov; 
        keep Col:;
     run;
   %end;
   %else %do;
     data _Parm; set &inest; run;
     data _Cov; set &incovb; run;
   %end;
   
   data _Parm; 
      set _Parm nobs=nobs; 
      call symput("dim",cats(nobs));
      Row=cats("p",_N_);
   run;

   /*
   /  Display parameter names for use in f= or fdata=.
   /------------------------------------------------------------------*/
   %if &score= %then %do;
     %if &listnames=Y %then %do;
       data _names; set _Parm;
          Name=cats("B_",Row);
       run;
       ods select all;
       proc print data=_names;
          id Name;
          var Estimate;
       run;
       ods exclude all;
     %end;
     %if %index(%upcase(&version),SHOWNAMES) %then %goto exit;
   %end;

   /*
   /  Create input data and list of variables in it.
   /------------------------------------------------------------------*/
   proc transpose data=_Parm(rename=(Row=_NAME_)) out=_tParm(drop=_NAME_);
      format Estimate best16.;
      var Estimate;
   run;
   proc transpose data=_tParm out=_ttParm;
   run;

   /* 
   /  Build list of Parameter names and values for NLMIXED.
   /------------------------------------------------------------------*/
   data _null_; set _ttParm;
      call symput("PInit",cats(symget("PInit"))||' '||
      'B_'||cats(_NAME_)||' '||cats(COL1));
   run;

   /* 
   /  Prepare covariance matrix.
   /------------------------------------------------------------------*/
   data _null_;
     set _cov nobs=nobs;
     array cols (*) _numeric_;
     if _n_=1 then 
     if nobs ne &dim or nobs ne dim(cols) then do;
       put "ERROR: Covariance matrix improper or incompatible with parameter
 vector.";
       call symput("status","bad_cov");
     end;
   run;
   %if &status=bad_cov %then %goto exit;
   proc transpose data=_cov out=_tcov(keep=Col:); 
      var _numeric_;
   run;

   /* 
   /  Invert covariance matrix.
   /------------------------------------------------------------------*/
   data _addI;
     array idmx{&dim} I1-I&dim;
     set _tcov;
     do _j=1 to &dim;
        if _j=_N_ then idmx[_j]=1;
        else idmx[_j]=0;
     end;
     drop _j;
   run;
   proc reg data=_addI outest=_CovInv(keep=Col:) noprint;
     model I1-I&dim = Col: / noint;
   run;quit;
   
   /* 
   /  Gather covariance values.
   /------------------------------------------------------------------*/
   data _likepieces;
     set _CovInv;
     array c(&dim) Col1-Col&dim;
     do j=1 to _n_;
       covlow=c(j);
       lhs=cats("p",_n_);
       rhs=cats("p",j);
       if j = _n_ then factor = 1;
       else factor = 2;
       keep covlow lhs rhs factor;
       output;
      end;
   run;

   %if %index(%upcase(&version),DEBUG) %then %do;
      proc print data = _likepieces;
      run;
   %end;

   data _likepieces;
      set _likepieces end = last;
   
      if _N_ = 1 then call symputx('midx',1);
      else do;
         if mod(_N_-1, &nrecdiv) = 0 then do;
            call symputx('midx', symgetN('midx')+1);
            end;
         end;
      
      if(_N_ = 1 and last = 1) then do;
         call symput('Expnt'||cats(symgetN('midx')), 
           cats(symget('Expnt'||cats(symgetN('midx'))))||
           cats(factor)||'*'||'('||trim(translate(lhs,"_","*"))||'-B_'||
           trim(translate(lhs,"_","*"))||')'||'*'||cats(covlow)||'*'||
           '('||trim(translate(rhs,"_","*"))||'-B_'||
           trim(translate(rhs,"_","*"))||')');
         end;
      else do;
         if (mod(_N_-1, &nrecdiv) = 0) then do;
            call symput('Expnt'||cats(symgetN('midx')),
              cats(factor)||'*'||'('||trim(translate(lhs,"_","*"))||'-B_'||
              trim(translate(lhs,"_","*"))||')'||'*'||cats(covlow)||'*'||
              '('||trim(translate(rhs,"_","*"))||'-B_'||
              trim(translate(rhs,"_","*"))||')'||'+');         
            end;
         
         else if (mod(_N_, &nrecdiv) = 0) then do;
            call symput('Expnt'||cats(symgetN('midx')), 
              cats(symget('Expnt'||cats(symgetN('midx'))))||
              cats(factor)||'*'||'('||trim(translate(lhs,"_","*"))||'-B_'||
              trim(translate(lhs,"_","*"))||')'||'*'||cats(covlow)||'*'||
              '('||trim(translate(rhs,"_","*"))||'-B_'||
              trim(translate(rhs,"_","*"))||')');
            end;
         else if last then do;
            call symput('Expnt'||cats(symgetN('midx')), 
              cats(symget('Expnt'||cats(symgetN('midx'))))||
              cats(factor)||'*'||'('||trim(translate(lhs,"_","*"))||'-B_'||
              trim(translate(lhs,"_","*"))||')'||'*'||cats(covlow)||'*'||
              '('||trim(translate(rhs,"_","*"))||'-B_'||
              trim(translate(rhs,"_","*"))||')');
            end;   
         else do;
            call symput('Expnt'||cats(symgetN('midx')), 
              cats(symget('Expnt'||cats(symgetN('midx'))))||
              cats(factor)||'*'||'('||trim(translate(lhs,"_","*"))||'-B_'||
              trim(translate(lhs,"_","*"))||')'||'*'||cats(covlow)||'*'||
              '('||trim(translate(rhs,"_","*"))||'-B_'||
              trim(translate(rhs,"_","*"))||')'||'+');
            end;
         end;
      run;

   /* 
   /  Use NLMIXED to compute estimate(s).
   /------------------------------------------------------------------*/
   %macro sum;
     %do i = 1 %to &midx-1;
        &&Expnt&i +
     %end;
     &&Expnt&midx;
   %mend;                  

   %if &fdata ne %then %do;
     data _null_; 
        set &fdata end=last nobs=nobs;
        if index(label,'"')>0 or index(f,'"')>0 then 
           call symput("status","quotes");
        call symput(cats("l",_n_),trim(label));
        call symput(cats("f",_n_),trim(f));
        if last then call symput("nf",nobs);
        run;
     %if &status=quotes %then %do;
   %put ERROR: Do not use double quotes (%str(%")) in the F or LABEL variable.;
   %put ERROR- Use single quotes (%str(%')).;
        %goto exit;
     %end;
   %end;
   
   %if &score ne %then %do;
     data _tParm;
       set _tParm &score(in=inscore);
       _inscore=0;
       if inscore then _inscore=1;
   %end;

   %if (^%length(&label)) %then %let label = &f;
   %if ( %length(&df)   ) %then %let df = df = &df;

   proc nlmixed data = _tParm;
    %if &score= %then 
      ods output AdditionalEstimates=Est;
    ;
      parms &PInit;
      _e =  %sum;
      _l = -0.5*_e;
      %if &score ne %then if _inscore=0 then;
      _dummy = 1;  
      model _dummy ~ general(_l);
    %if %quote(&f) ne %then %do;
      %if &score ne %then %do;
          predict &f out=&outscore(where=(_inscore=1)) &df
            %if &alpha ne %then alpha=&alpha;
          ;
      %end;
      %else %do;
        estimate "&label" &f &df
          %if &alpha ne %then alpha=&alpha;
        ;
      %end;
    %end;
    
    %if &fdata ne %then %do i=1 %to &nf;
      estimate "&&l&i" &&f&i &df
        %if &alpha ne %then alpha=&alpha;
      ;    
    %end;

    run;
   %if &syserr=3000 %then %do;
      %put ERROR: PROC NLMIXED in SAS/STAT is required.;
      %goto exit;
   %end;

   %if &score ne %then %do;
      data &outscore;
        set &outscore nobs=nobs;
        call symput("nobs",cats(nobs));
        %if &df = %then %do;
           Lower = Pred - probit(1-&alpha/2)*StdErrPred;
           Upper = Pred + probit(1-&alpha/2)*StdErrPred;
           ChiSq = tValue**2; Pr = 1-probchi(ChiSq,1);
           format Pr pvalue6.;
           label ChiSq = "Wald Chi-Square" Pr = "Pr > ChiSq";
           drop df tValue Probt;
        %end;
        drop _inscore;
        run;
      options notes;
      %put NOTE: The data set %upcase(&outscore) has &nobs observations.;
      %if %index(%upcase(&version),DEBUG)=0 %then options nonotes;;
   %end;
   %else %do;
      ods select all;
      %if %quote(&title) ne %then %do; 
        title "%quote(&title)";
      %end;
      %else %do;
        title "Nonlinear Function Estimate";
      %end;
      %if &df = %then %do;
	 data Est;
	   set Est;
	   Lower = Estimate - probit(1-&alpha/2)*StandardError;
	   Upper = Estimate + probit(1-&alpha/2)*StandardError;
	   ChiSq = tValue**2; Pr = 1-probchi(ChiSq,1);
	   format Pr pvalue6.;
	   label ChiSq = "Wald Chi-Square" Pr = "Pr > ChiSq";
	   drop df tValue Probt;
	   run;
	 proc print data=Est label;
	   id label;
	   var Estimate StandardError ChiSq Pr Alpha Lower Upper;
	   run;
      %end;
      %else %do;
	 proc print data=Est label;
	   id label;
	   run;
      %end;
      ods exclude all;
   %end;

%exit:
   /* 
   /  Delete temporary data sets; turn output and notes back on.
   /------------------------------------------------------------------*/
   %if %index(%upcase(&version),DEBUG)=0 %then %do;
     %if &status=ok %then %do;
       proc datasets nolist; 
         delete _Parm _names _Cov  
         %if %index(%upcase(&version),SHOWNAMES)=0 %then
                _tParm _ttParm _tcov _addI _CovInv _likepieces;
         ;
         run; quit;
     %end;
     %else %if &status=bad_cov %then %do;
       proc datasets nolist; 
         delete _Parm _names _Cov _tParm _ttParm;
         run; quit;
     %end;
     %else %if &status=quotes %then %do;
       proc datasets nolist; 
         delete _Parm _names _Cov _tParm _ttParm _tcov _addI 
                _CovInv _likepieces;
         run; quit;
     %end;
   %end;
   %else %do;
     %put status = &status;
     %put midx   = &midx;
     %put Expnt1 = &Expnt1;   
     %put PInit  = &PInit;
     %put dim    = &dim;
   %end;   

   %if %index(%upcase(&version),DEBUG) %then %do;
    options nomprint nomlogic nosymbolgen;
    %put _user_;
   %end;
   ods select all;
   options &notesopt;
   title;
   %let time = %sysfunc(round(%sysevalf(%sysfunc(datetime()) - &time), 0.01));
   %put NOTE: The NLEstimate macro used &time seconds.;
%mend;

