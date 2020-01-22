

/********************************************************************
	* Job Name: jhu_case_definitions_crohns.sas
	* Job Desc: Identify Crohn's disease cases using claims data
	* See corresponding manuscript (Table 2): ENTER WHEN READY
	* Copyright: Johns Hopkins University - HutflessLab 2019
	********************************************************************/
	
	/********************************************************************
	* INSTRUCTIONS:
	* This program uses publicly available CMS sytnthetic data to
	* illustrate how one can identify the number of cases of
	* Crohn's disease using all of the case definitions associated
	* with validation studies in the literature through MONTH 2020.
	* You can also run the program on any claims data set that uses
	* ICD coding by modifying the variable names in the %let
	* statements.
	*
	* You can download the CMS synthetic data and codebooks at
	* https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/index.html
	* https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/DESample01
	* We have also downloaded the .SAS and .CSV files here:
	* https://livejohnshopkins-my.sharepoint.com/:f:/r/personal/shutfle1_jh_edu/Documents/Synthetic%20datasets?csf=1&e=e9XAUd
	*
	* This program is divided into various parts that are sequential.
	* Part 1: Set up the CMS synthetic dataset

	* Part 2: Insert %let statements for use on any dataset configured as 
           the CMS Synthetic datasets created in Part 1. Create a 1 record
			per person analytic file.
	*
	* Part 3: Program that creates each case definition and outputs
	*         tables with the case definitions so that the user can
	*         compare the number of patients identified from their
	*         cohort using each validated case definition.
	* NOTE:   The program assumes that you are using the correct
	*         types of datsets (inpatient/outpatient) based on the
	*         characteristics of the cohort used to calculate the
	*         diagnostic accuracy in each validation study.
	*         We have added these characteristics to this program,
	*         but it is up to the user to confirm that they are
	*         using the definition appropriately.

	* Part 4: Set up formats and use an external macro to
	*         summarize case definitions in a single macro
	*********************************************************************/
	
	/********************************************************************
	* Need Help with SAS?
	* If you have questions about using SAS or its syntax, we suggest:
	*    https://www.sas.com/en_us/learn/academic-programs/resources/free-sas-e-learning.html
	*    https://stats.idre.ucla.edu/sas/
	*    https://www.lexjansen.com/
	* Ask questions in the SAS community: https://communities.sas.com/
	*    Take a look if someone has already asked/answer your
	*    questions & at how others ask questions before posting your own
	* This program was created in SAS Enterprise. SAS 9.4 is known to have
		difficulties with the death dates.  Use Enterprise if possible.
	********************************************************************/

	/*** part 1 section - BEG -- START ***/
	/*** part 1 section - BEG -- START ***/
	/*** part 1 section - BEG -- START ***/
/****Part 1: Set up CMS Synthetic data***/

/* Identify where you downloaded synthetic data onto your machine  */
libname synth "C:\Users\shutfle1\OneDrive - Johns Hopkins\Synthetic datasets";
libname synth2 "S:\CMS\CMS synth data";
run;

/* First you need to examine your datasets.  Read the codebook then examine your SAS files.
	Identify variables (proc contents), look at data directly (proc print), 
	examine uniqely identified variables (proc sort no dupkey),
	look at missing numeric variables (proc means nmiss).
	These should be done for all datasets at the start of every project.
	Here we give an example of checking 1 of the datasets used to set up the synthetic data*/

proc contents data=synth2.carrier_sample_1a;
run;
proc print data=synth2.carrier_sample_1a (obs=20);
run;
/**Check for duplicates in the datasets **/
proc sort data=synth2.carrier_sample_1a NODUPKEY out= work.try dupout=dupes;
by desynpuf_id clm_id clm_thru_dt;
run;
proc means nmiss data=synth2.carrier_sample_1a; run;


/*We are going to read in the claims, enrollment and medications files
	--these are all of the files we will need for our analysis**/

/* Concatenate (make 1 dataset) of all claims files: 
	carrier, inpatient, and outpatient datasets */
data work.diag;
set
synth2.carrier_sample_1a (obs=200000)
synth2.carrier_sample_1b (obs=200000)
synth.inpatient_sample_1 (drop = HCPCS_CD_14 - HCPCS_CD_44)
synth.outpatient_sample_1;
run;

data claims;
    set work.diag;
/*Look at the year part of the claim date, year4 is a special format for the cms synthetic data*/
    year = put(CLM_FROM_DT,year4.);
    /* make a few fake ICD-10 codes for CD and UC so we can check the ICD 10 code since the dataset is 2008-2010 pre icd-10 */
    if substr(icd9_dgns_cd_1,1,3)='250' then icd10_dgns_cd_1='K500';
    if substr(icd9_dgns_cd_2,1,3)='250' then icd10_dgns_cd_2='K500';
	if substr(icd9_dgns_cd_3,1,3)='250' then icd10_dgns_cd_3='K500';
	if substr(icd9_dgns_cd_4,1,3)='250' then icd10_dgns_cd_4='K500';
	if substr(icd9_dgns_cd_5,1,3)='250' then icd10_dgns_cd_5='K500';
	if substr(icd9_dgns_cd_6,1,3)='250' then icd10_dgns_cd_6='K500';
	if substr(icd9_dgns_cd_7,1,3)='250' then icd10_dgns_cd_7='K500';
	if substr(icd9_dgns_cd_8,1,3)='250' then icd10_dgns_cd_8='K500';
	if substr(icd9_dgns_cd_9,1,3)='250' then icd10_dgns_cd_9='K500';
	if substr(icd9_dgns_cd_10,1,3)='250' then icd10_dgns_cd_10='K500';

    if icd9_dgns_cd_1='0389' then icd10_dgns_cd_1='K510';
    if icd9_dgns_cd_2='0389' then icd10_dgns_cd_2='K510';
	if icd9_dgns_cd_3='0389' then icd10_dgns_cd_3='K510';
	if icd9_dgns_cd_4='0389' then icd10_dgns_cd_4='K510';
	if icd9_dgns_cd_5='0389' then icd10_dgns_cd_5='K510';
	if icd9_dgns_cd_6='0389' then icd10_dgns_cd_6='K510';
	if icd9_dgns_cd_7='0389' then icd10_dgns_cd_7='K510';
	if icd9_dgns_cd_8='0389' then icd10_dgns_cd_8='K510';
	if icd9_dgns_cd_9='0389' then icd10_dgns_cd_9='K510';
	if icd9_dgns_cd_10='0389' then icd10_dgns_cd_10='K510';
run;
proc freq data=claims;
table year;
run;

/*Now read in the enrollment file and make it into a 1 record per person file*/
/*Use a macro to bring in the enrollment info.  Macros are useful when you are going
	to do the same thing to 2 datasets with similar setup--like our situation
	where enrollment info looks the same for each calendar year**/	
/* Why do you we need enrollment info?  
	   Some case definitions take into account time under follow-up
	   before and after Crohn's disease diagnosis.  We will make Medicare
	   coverage start and end variables from the beneficiary
	   summary enrollment file. The beneficiary summary data is 1 record
	   per person and a person contributes to each year that
	   they were a Medicare beneficiary.  So we are going to make
	   a Medicare coverage start and end variable for the
	   entire 2008-2010 period in a 1 record per person dataset to
	   merge with claims.  
	*/

/*EDITS NEEDED: problem with date of death--convert csv to sas again to fix**/
	%macro mbsf(in=, out=, covstart1=, covstart2=);
	
	data &out (keep=  desynpuf_id
	                  bene_birth_dt
					  bene_death_dt
	                  bene_race_cd
	                  bene_sex_ident_cd
	                  &covstart1);
	set &in;
	&covstart1=&covstart2;
	format &covstart1 date9.;
	run;
	
	proc sort data=&out nodupkey;
	by desynpuf_id;
	run;
	
	%mend;
	
	%mbsf(in=synth.beneficiary2008_sample_1, out=bene2008, covstart1=covstart2008, covstart2='01jan2008'd);
	%mbsf(in=synth.beneficiary2009_sample_1, out=bene2009, covstart1=covstart2009, covstart2='01jan2009'd);
	%mbsf(in=synth.beneficiary2010_sample_1, out=bene2010, covstart1=covstart2010, covstart2='01jan2010'd);

	/*look at dataset before and after to check if did what you wanted it to*/
	proc print data=synth.beneficiary2008_sample_1 (obs=10); where bene_death_dt ne .; run;
	proc print data=bene2008 (obs=10); where bene_death_dt ne .; run;

		/***Make a single 1 record per person file with enrollment info***/
	data mbsf2008_2010
	      (drop = endcohort
	              covstart2008
	              covstart2009
	              covstart2010
	              );
	merge
	bene2008
	bene2009
	bene2010
	;
	by desynpuf_id;
	covstart    = min(covstart2008, covstart2009, covstart2010);
	endcohort   = '31dec2010'd;
	covend      = min(endcohort, bene_death_dt);
	label covstart   = 'beginning of medicare coverage';
	label covend     = 'end of medicare coverage';
	format bene_birth_dt bene_death_dt covstart covend date9.;
	run;
	proc print data=mbsf2008_2010 (obs=10); where covend ne '31dec2010'd; run;
	/*confirm there are no duplicates*/
	proc sort data=mbsf2008_2010 nodupkey out=try; by desynpuf_id; run;
	
	/* Medications */
	/* Some case definitions require use of medications */

	/**Download the product and package files from FDA
		https://www.fda.gov/drugs/drug-approvals-and-databases/national-drug-code-directory
		The SAS converted versions of these files are available 
			in the public file with the downloaded CMS Synth data.
		Note: The product and package files are updated regularly. This
			study's downloaded files may be out of date**/
	/**Now read in the medications--THIS IS 1 ROW PER ndc**/

	data ndc (keep= ndc nonproprietaryname proprietaryname pharm_classes);
	merge
	synth.ndc_product
	synth.ndc_package
	;
	   by productid;
	   length ndc 8.;
	   ndc_an =compress(ndcpackagecode,"-");
	   ndc    = ndc_an *1;
	   drop ndc_an;
	   nonproprietaryname = upcase(nonproprietaryname);
	   proprietaryname = upcase(proprietaryname);
	   pharm_classes = upcase(pharm_classes);
	run;
proc contents data=ndc; run;
proc freq data=ndc; where nonproprietaryname contains 'MYCIN'; table pharm_classes;run;
	
data pde;
length ndc 8.;
set synth.prescription_sample_1;
ndc=prod_srvc_id*1;
run;
proc sort data=pde; by ndc;
proc sort data=ndc; by ndc;
run;

data pde_ndc;
merge pde (in=a) ndc (in=b);
by ndc;
if a and b; 
run;
	
	/*** part 1 section - END ***/
	/*** part 1 section - END ***/
	/*** part 1 section - END ***/
	
	
	
	
	/*** part 2 section - BEG - Start ***/
	/*** part 2 section - BEG - Start ***/
	/*** part 2 section - BEG - Start ***/
/*Use %let so can apply the program to any dataset that is set up in
	the same format as our CMS Synthetic data (1 record per person
	enrollment, 1 record per claim, 1 record per medication fill*/
/*If you are not using the CMS synthetic data, set up your variables to match
	your dataset and this should work (as long as formatting the same*/
	
%let lwork             = work                ;
%let icd9_10_cutoff_dt = '31oct2015'd        ;
%let synth_lib         = synth               ;
%let year1             = 2008                ; /* project year 1 */
%let year2             = 2009                ; /* project year 2 */
%let year3             = 2010                ; /* project year 3 */
%let min_year          = &year1              ; /* first year of project */
%let max_year          = &year3              ; /* max year of project */
%let icd_pfx           = icd                 ; /* common prefix for icd codes */
%let enc_year          = enc_year            ; /* name of variable associated with year of encounter */
%let diag_i9_pfx       = &icd_pfx.9_dgns_cd_ ; /* diagnosis code prefix - specific to icd9  */
%let diag_i10_pfx      = &icd_pfx.10_dgns_cd_; /* diagnosis code prefix - specific to icd10 */
%let hcpcs_pfx         = hcpcs_cd_           ; /* hcpcs prefix */
%let diag_min          = 1                   ; /* diag code first val */
%let diag_max          = 10                  ; /* diag code max val */
%let pat_id            = desynpuf_id         ; /* unique patient identifier */
%let clm_beg_dt        = clm_from_dt         ; /* date associated with claim */
%let clm_end_dt        = clm_thru_dt         ; /* claim thru dt */
%let pat_dob           = bene_birth_dt       ; /* add date of birth */
%let pat_gender        = bene_sex_ident_cd   ; /* add in sex/gender variable */
%let pat_race          = bene_race_cd        ; /* beneficiary race code */
%let pat_dod           = bene_death_dt       ; /* beneficiary date of death on beneficiary denom data */
%let elig_start_dt        = covstart      ; 		/* benefit start date - imputed */
%let elig_end_dt        = covend      ; 		/* benefit end date - imputed */
%let flag_icd910       = flag_icd910         ; /* flag indicating if claim is i9 or i10 */
%let flag_uc_pfx       = uc_ ;
%let flag_cd_pfx       = cd_ ;
%let flag_ibd_pfx       = ibd_ ;
%let flag_uc_i9        = &flag_uc_pfx.9;
%let flag_cd_i9        = &flag_cd_pfx.9;
%let flag_ibd_i9        = &flag_ibd_pfx.9;
%let flag_uc_i10       = &flag_uc_pfx.10;
%let flag_cd_i10       = &flag_cd_pfx.10;
%let flag_ibd_i10       = &flag_ibd_pfx.10;
%let prescription		= &lwork..pde_ndc; /*this indicates where your 1 record per
											prescription file is*/
%let ndc				= ndc;			/*identifier for prescription id*/
%let prescription_dt	= srvc_dt ;		/*date of prescription fill*/

/*merge claims with beneficiary info*/
proc sort data=	&lwork..claims; by &pat_id;
proc sort data= &lwork..mbsf2008_2010; by &pat_id;
run;

data &lwork..claims2;
merge 
&lwork..claims (in=a) 
&lwork..mbsf2008_2010 (in=b);
by &pat_id;
if a and b;
run; *the rows here should match the rows in claims;

/*identify claims for CD and UC*/
	data &lwork..crohns_count1 (keep = &pat_id
									&pat_dob
									&pat_gender 
									&pat_race
									&elig_start_dt
									&elig_end_dt
                                    &clm_beg_dt
                                    &flag_uc_i9
                                    &flag_cd_i9
									&flag_ibd_i9
                                    &flag_uc_i10
                                    &flag_cd_i10
									&flag_ibd_i10
                                    );
	set
	&lwork..claims2;* (obs=20000);
	/* Create year of diagnosis from the claim date,
	   year4 is a special format for the cms synthetic data*/
	    year = put(&clm_beg_dt ,year4.);
/*delete claims outside of time period of interest*/
	if year<&min_year then delete;
	if year>&max_year then delete;
/* Indicate if data is icd 9 or 10 for date based on year
	       (will have all icd-9 because years are 2008-2010*/
	        flag_icd910=0;
	        if &clm_beg_dt  le &icd9_10_cutoff_dt then do;
	        flag_icd910=9;
	        end;
	        if &clm_beg_dt  gt &icd9_10_cutoff_dt then do;
	        flag_icd910=10;
	        end;
	        label flag_icd910='indicator if dx code is 9 or 10 based on date of claim';
/*identify claims for crohn and ulcerative colitis--only keep those claims*/
/*need 1 array for ICD-9 and 1 array for ICD-10*/
    if &min_year <= year <= &max_year then do;
    array  dgns9 (&diag_max) &diag_i9_pfx.&diag_min  - &diag_i9_pfx.&diag_max ;
            do i=&diag_min to &diag_max;
            if substr(dgns9(i),1,3)='555' then &flag_cd_i9=1;
            if substr(dgns9(i),1,3)='556' then &flag_uc_i9=1;
			if substr(dgns9(i),1,3) in('555','556') then &flag_ibd_i9=1;
            end;
    end;

    if &min_year <= year <= &max_year then do;
    array  dgns10 (&diag_max) &diag_i10_pfx.&diag_min  - &diag_i10_pfx.&diag_max ;
            do t=&diag_min to &diag_max;
            if substr(dgns10(t),1,3)='K50' then &flag_cd_i10=1;
            if substr(dgns10(t),1,3)='K51' then &flag_uc_i10=1;
			if substr(dgns10(t),1,3) in('K50','K51') then &flag_ibd_i10=1;
            end;
    end;

    if &flag_uc_i9  = . and
       &flag_cd_i9  = . and
       &flag_uc_i10 = . and
       &flag_cd_i10 = .
       then delete;
run;

	/**  We want to count the number of visits/encounters for CD / UC.
	     We are going to count up the encounters for cd in icd-9 and
	     icd-10 and for uc in icd-9 and icd-10.  We are counting up
	     UC because some case definitions allow patients to have
	     encounters for UC despite actually having Crohn's disease
	     If you have questions about using counts with
	     a by statement check out:
	     https://blogs.sas.com/content/iml/2018/02/26/how-to-use-first-variable-and-last-variable-in-a-by-group-analysis-in-sas.html
	     */
	
%macro counts(code= , code_count= , date_code= , age_code=, label1= , label2=, label3=);

proc sort data=&lwork..crohns_count1    NODUPKEY;
by &pat_id  &clm_beg_dt &flag_uc_i9  &flag_cd_i9  &flag_uc_i10 &flag_cd_i10 ;
run;

data &code (keep = 					&pat_id 
					&date_code 
					&code_count 
					&age_code
									&pat_dob
									&pat_gender 
									&pat_race
									&elig_start_dt
									&elig_end_dt);
set
&lwork..crohns_count1;
by  &pat_id &clm_beg_dt;
where &code=1; 
if first.&pat_id then do;
    &date_code = &clm_beg_dt ; /* if the first. statement was not used then this variable would label every claim_dt as the first cd/uc claim date */
	&age_code=(&clm_beg_dt-&pat_dob)/365.25;
    &code_count=0;
end;
 	&code_count+1;			/* the counter +1 must be after end so the counter applies beyond first.variable */

 if last.&pat_id then output;

 label &code_count = &label1;
 label &date_code  = &label2;
 label &age_code=&label3;
 format &date_code date9.;
run;

/* check to see if the counter worked */
/* generally people have more than 1
   encounter---if everyone only has 1
   encounter then your dataset could be
   set up as 1 record per person or there is
   a problem with the counting part of the data step */

proc freq data=&code;
table &code_count;
run;
%mend;  /*** mend corresponds to macro counts above
		need "%macro counts()" above and "%counts" below to work ***/

%counts(code =	&flag_cd_i9 , code_count = cd9_count ,  
				date_code = cd9_date_first  , age_code=cd9_age_first ,
	label1 = 'Number of Crohns encounters in ICD-9', 
	Label2 = 'Date of first CD diagnosis in ICD-9',
	label3='Age of first CD diagnosis in ICD-9');
%counts(code =	&flag_uc_i9 , code_count = uc9_count ,  
				date_code = uc9_date_first  , age_code=uc9_age_first ,
	label1 = 'Number of ulcerative colitis encounters in Icd-9', 
	Label2 = 'Date of first uc diagnosis in Icd-9',
	label3='Age of first uc diagnosis in Icd-9');
%counts(code =	&flag_ibd_i9 , code_count = ibd9_count ,  
				date_code = ibd9_date_first  , age_code=ibd9_age_first ,
	label1 = 'Number of ulcerative colitis encounters in Icd-9', 
	Label2 = 'Date of first ibd diagnosis in Icd-9',
	label3='Age of first ibd diagnosis in Icd-9');
%counts(code =	&flag_cd_i10 , code_count = cd10_count ,  
				date_code = cd10_date_first  , age_code=cd10_age_first ,
	label1 = 'Number of Crohns encounters in ICD-10', 
	Label2 = 'Date of first CD diagnosis in ICD-10',
	label3='Age of first CD diagnosis in ICD-10');
%counts(code =	&flag_uc_i10 , code_count = uc10_count ,  
				date_code = uc10_date_first  , age_code=uc10_age_first ,
	label1 = 'Number of ulcerative colitis encounters in Icd-10', 
	Label2 = 'Date of first uc diagnosis in Icd-10',
	label3='Age of first uc diagnosis in Icd-10');
%counts(code =	&flag_ibd_i10 , code_count = ibd10_count ,  
				date_code = ibd10_date_first  , age_code=ibd10_age_first ,
	label1 = 'Number of ulcerative colitis encounters in Icd-10', 
	Label2 = 'Date of first ibd diagnosis in Icd-10',
	label3='Age of first ibd diagnosis in Icd-10');


/**combine datasets for unique days of uc9 and cd9*/
data &lwork..cduc (keep=&pat_id 
						&pat_dob
						&pat_gender 
						&pat_race
						&elig_start_dt
						&elig_end_dt 
						cd9: uc9: cd10: uc10: ibd9: ibd10:);
/**keep statement note: anything starting with the variable after the colon will be included*/
    merge
    &flag_cd_i9
    &flag_uc_i9
	&flag_ibd_i9
    &flag_cd_i10
    &flag_uc_i10
	&flag_ibd_i10;
    by &pat_id;
    if cd9_count =. then cd9_count=0;
    if uc9_count =. then uc9_count=0;
	if ibd9_count =. then ibd9_count=0;
    cd9_prop     =cd9_count/ibd9_count;
    if cd10_count=. then cd10_count=0;
    if uc10_count=. then uc10_count=0;
	if ibd10_count=. then ibd10_count=0;
    cd10_prop    =cd10_count/ibd10_count;
	cd_date_first  = min(cd9_date_first,cd10_date_first); 
	ibd_date_first = min(cd9_date_first,cd10_date_first, uc9_date_first,uc10_date_first);
cd_age_dx   = (cd_date_first - &pat_dob)/365.25;
ibd_age_dx  = (ibd_date_first - &pat_dob)/365.25;
fuptoCD    = cd_date_first    - &elig_start_dt ; 
fupafterCD = &elig_end_dt     - cd_date_first ; 
label cd_age_dx  	= 'Age at first CD encounter';
label ibd_age_dx 	= 'AGe at first IBD encounter'; 
label fuptoCD		= 'Time between start of Medicare coverage and CD diagnosis date';
label fupafterCD	= 'Time between first CD encounter and death or end of followup'; 
	       label cd_date_first  =       'Date of first encounter for Crohns';
	       label ibd_date_first =       'Date of first encounter for IBD ';
	       label cd9_prop               =     'Proportion of ICD-9 counter that were Crohn encounters';
	       label cd10_prop       =     'Proportion of ICD-10 counter that were Crohn encounters';
		   label ibd9_count = 'Number of IBD encounters (CD or UC) in icd-9';
		   label ibd10_count = 'Number of IBD encounters (CD or UC) in icd-10';
run; 

proc print data=cduc (obs=20);
run;
proc contents data=cduc; run;
proc means data=&lwork..cduc
      n mean median p25 p75 min max;
      var cd9: uc9: cd10: uc10: ibd9: ibd10:;
run;

/*identify drugs of interest*/
data pde_ndc2; set &prescription;
		if pharm_classes = "Aminosalicylate [EPC],Aminosalicylic Acids [CS]"
			then drug_5asa=1;
		if pharm_classes = "CORTICOSTEROID [EPC],CORTICOSTEROID HORMONE RECEPTOR AGONISTS [MOA]"
			then drug_steroids=1;
	   	if substr(NONPROPRIETARYNAME,1,12) = 'METHOTREXATE' then do;
	   		drug_MTX=1;
			drug_immunomodulator=1;
		end;
	 	if substr(NONPROPRIETARYNAME,1,12) = 'AZATHIOPRINE' then do;
	   		drug_AZA=1;
			drug_immunomodulator=1;
		end;
		if NONPROPRIETARYNAME = 'MERCAPTOPURINE' then do;
	   		drug_6mp=1;
			drug_immunomodulator=1;
		end;
		if NONPROPRIETARYNAME in:('INFLIXIMAB') then do;
	   		drug_inflix=1;
			drug_antiTNF=1;
			drug_biologic=1;
		end;
		if NONPROPRIETARYNAME in:( 'ADALIMUMAB') then do;
	   		drug_ada=1;
			drug_antiTNF=1;
			drug_biologic=1;
		end;
		if NONPROPRIETARYNAME in:( 'CERTOLIZUMAB') then do;
	   		drug_cert=1;
			drug_antiTNF=1;
			drug_biologic=1;
		end;
		if NONPROPRIETARYNAME in:( 'NATALIZUMAB') then do;
	   		drug_natal=1;
			drug_biologic=1;
		end;
		if NONPROPRIETARYNAME in:( 'USTEKINUMAB') then do;
	   		drug_ust=1;
			drug_biologic=1;
		end;
		if NONPROPRIETARYNAME in:( 'VEDOLIZUMAB') then do;
	   		drug_vedo=1;
			drug_biologic=1;
		end;
	run;
	data pde_ndc_abx; set &prescription;
	where pharm_classes contains "ANTIBACTERIAL"; 
	drug_antibiotics=1;
	run;

data pde_ndc3;
set pde_ndc2 pde_ndc_abx;
run;

/*use a proc print to make sure you have all of your drugs*/
	proc print data=pde_ndc3; where NONPROPRIETARYNAME contains 'INFLIXIMAB'; run;
	proc freq data=pde_ndc3; table pharm_classes; run;
	
%macro counts(code= , code_count= , date_code= , age_code=, label1= , label2=, label3=);

proc sort data=&lwork..pde_ndc3    NODUPKEY;
by &pat_id  &prescription_dt &ndc drug:;
run;

data &code (keep = 	&pat_id 
					&date_code 
					&code_count );
set
&lwork..pde_ndc3;
by  &pat_id &prescription_dt;
where &code=1; 
if first.&pat_id then do;
    &date_code = &prescription_dt; /* if the first. statement was not used then this variable would label every claim_dt as the first cd/uc claim date */
    &code_count=0;
end;
 	&code_count+1;			/* the counter +1 must be after end so the counter applies beyond first.variable */

 if last.&pat_id then output;

 label &code_count = &label1;
 label &date_code  = &label2;
 format &date_code date9.;
run;
proc freq data=&code;
table &code_count;
run;
%mend;  /*** mend corresponds to macro counts above
		need "%macro counts()" above and "%counts" below to work ***/

%counts(code =	drug_biologic, code_count = drug_biologic_count ,  
				date_code = drug_biologic_date_first  , 
	label1 = 'Number of biologic prescription fills', 
	Label2 = 'Date of first biologic prescription fill');
%counts(code =	drug_antibiotics, code_count = drug_antibiotics_count ,  
				date_code = drug_antibiotics_date_first  , 
	label1 = 'Number of antibiotics prescription fills', 
	Label2 = 'Date of first antibiotics prescription fill');
%counts(code =	drug_immunomodulator, code_count = drug_immunomodulator_count ,  
				date_code = drug_immunomodulator_date_first  , 
	label1 = 'Number of immunomodulator prescription fills', 
	Label2 = 'Date of first immunomodulator prescription fill');
%counts(code =	drug_steroids, code_count = drug_steroids_count ,  
				date_code = drug_steroids_date_first  , 
	label1 = 'Number of steroids prescription fills', 
	Label2 = 'Date of first steroids prescription fill');
%counts(code =	drug_5asa, code_count = drug_5asa_count ,  
				date_code = drug_5asa_date_first  , 
	label1 = 'Number of 5asa prescription fills', 
	Label2 = 'Date of first 5asa prescription fill');
/*this macro counter can be used for specific drugs in addition to drug class*/
	data drugs;
	merge drug_biologic drug_antibiotics drug_immunomodulator drug_steroids drug_5asa; 
	by &pat_id;
	run;
/*make sure there is only 1 record per person (no dupes)*/
	proc sort data=drugs nodupkey out=try; by &pat_id; run;

/*merge drug info with the IBD info*/
proc sort data=drugs; by &pat_id;
proc sort data=&lwork..cduc; by &pat_id;
run;

data &lwork..cduc2;
merge &lwork..cduc (in=a)
drugs (in=b);
by &pat_id;
if a;
run;

	/*** part 2 section - END ***/
	/*** part 2 section - END ***/
	/*** part 2 section - END ***/
	
	
	
	
	/*** part 3 section - BEG - Start ***/
	/*** part 3 section - BEG - Start ***/
	/*** part 3 section - BEG - Start ***/



/*  Now that our 1 record per person dataset is set up with
    counts of CD/UC/IBD and demographic info, we can start
    to apply the validated case definitions from the
    literature to our cohort.
    We will name each dataset the name of the validation study.
    We have grouped the validation studies by commonalities in
    case definitions.  
    */

/*  There are N studies that use ICD-9 diagnoses
    for their case definitions */

data work.DiDomenicantonio2014;
set
&lwork..cduc2
;
if cd9_count  <   1 then delete;
if uc9_count  >=  1 then delete;
run;


title1 'DiDomenicantonio 2014 (PMID:24890621 )';
title2 'At least 1 ICD-9 555.x during hospitalization. If UC [556.x] then exclude';
title3 'Italy';
title4  'Validation years: 2000-2009';
title5  'Inpatient only';
title6  'No minimum follow-up';
title7  'No age restriction';
title8  'Sensitivity 82.2%';
        

proc means data=work.DiDomenicantonio2014   n mean median min max;
var cd9: uc9: cd10: uc10: ibd9: ibd10: &elig_start_dt
									&elig_end_dt;
run;

proc freq data=work.DiDomenicantonio2014;
table &pat_gender &pat_race drug:;
run;

/*below have not been checked*/
data Herrinton2007;
set &lwork..cduc2;
if cd9_count<1 then delete;
age_cd_dx=min(cd9_age_first, cd10_age_first);
/*add duration of followup based on cd date first and end of follow-up variables*/
run;

title1 'Herrinton2007 (PMID:17219403 );
        *= 1 ICD-9 555.x;
        *United States
        Validation years: 1999-2001
        Inpatient or outpatient
        No minimum follow-up
        No age restriction
        PPV 18-67%';

proc means data=Herrinton2007 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;;
run;

proc freq data=Herrinton2007;
table &sex;
run;




data Herrinton2008;
set cduc;
if cd9_count<1 then delete;
run;

ods pdf file='S:\CMS\CMS synth data\Herrinton2008.pdf';
title1 'Herrinton2008/Liu 2009 (PMID:18796097);
        *= 1 ICD-9 555.x;
        *United States
        Validation years: 1996-2001
        Inpatient or outpatient
        No minimum follow-up
        = 12 months of enrollment
        No age restriction
        Sensitivity 83%
        PPV 74-82%';

proc means data=Herrinton2008 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=Herrinton2008;
table sex;
run;
ods pdf close;

data Thirumurthi2010;
set cduc;
if cd9_count<1 then delete;
if age<18 then delete;
run;

*need to take a look at the observations due to the age variable;
ods pdf file='S:\CMS\CMS synth data\Thirmurthi2010.pdf';
Title 'Thirumurthi 2010 (PMID:20033847);
        *= 1 ICD-9 555.0, 555.1, 555.2, OR 555.9 (no mention of exclusions);
        *United States
        Validation years: 2000-2004
        Inpatient or Outpatient
        Adults (military veterans)
        Sensitivity 92% Specificty 99% PPV 88% NPV 99%';

proc means data=Thirumurthi2010 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=Thirumurthi2010;
table sex;
run;
ods pdf close;

data Ananthakrishnan2013;
set cduc;
if cd9_count<1 then delete;
run;

ods pdf file='S:\CMS\CMS synth data\Ananthakrishnan2013.pdf';
Title 'Ananthakrishnan 2013 (PMID:23451882);
        *= 1 ICD-9 555.x or 556.x;
        *United States
        Validation years: Not reported
        Inpatient or Outpatient
        No minimum follow-up
        No age restriction
        Sensitivity 92% Specificty 99% PPV 88% NPV 99%';

proc means data=Ananthakrishnan2013 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=Ananthakrishnan2013;
table sex;
run;
ods pdf close;


data Hou2014;
set cduc;
if cd9_count<1 then delete;
if uc9_count>=1 then delete;
if age<18 then delete;
run;

ods pdf file='S:\CMS\CMS synth data\Hou2014.pdf';
Title 'Hou 2014 (PMID:24817338);
        *= 1 ICD-9 555.x exclude 556.x;
        *United States
        Validation years: 1999-2009
        Inpatient or Outpatient
        No minimum follow-up
        Adults (military veterans)
        PPV 60%';

proc means data=Hou2014 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=Hou2014;
table sex;
run;

ods pdf close;

data Restrepo2016;
set cduc;
if cd9_count<1 then delete;
run;

ods pdf file='S:\CMS\CMS synth data\Restrepo.pdf';
Title 'Restrepo 2016 (PMID:27812365);
        *= 1 ICD-9 555.x in electronic health record
          AND = 1 mention of 5-aminosalicylate, antibiotic,
          corticosteroid, immunomodulatory, anti-TNF or natalizumab;
        *United States
        Validation years: Not reported
        EHR (Inpatient or Outpatient)
        No minimum follow-up
        No age restriction
        PPV 100%';
        **Need to incorporate medication;

proc means data=Restrepo2016 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=Restrepo2016;
table sex;
run;

ods pdf close;


**ICD 10 case defintions only;


data Sepaniuk2015;
set cduc;
if cd10_count<1 then delete;
if age<65 then delete;
run;

ods pdf file='S:\CMS\CMS synth data\Stepaniuk2015.pdf';
Title 'Stepaniuk 2015 (PMID:25874650);
        *= 1 ICD-10 K50.x as primary diagnosis during hospitalization;
        *Canada
        Validation years: 2007-2012
        Inpatient only
        No minimum follow-up
        Adults Adults (= 65)
        Sensitivity 98% NPV 99%';

proc means data=tepaniuk2015 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=tepaniuk2015;
table sex;
run;

ods pdf close;

ods pdf file='S:\CMS\CMS synth data\Ma2017.pdf';
Title 'Ma 2017 (PMID:29087396);
        *= 1 ICD-10 K50.0, K50.1 or K50.8 during hospitalization exclude K51.x;
        *Canada
        Validation years: 2011
        Inpatient only
        No minimum follow-up
        Adults Adults (= 18)
        Sensitivity 30-95% Specificity 89-99% NPV 66-99% PPV 67-97%';
proc means data=tepaniuk2015 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=tepaniuk2015;
table sex;
run;

ods pdf close;


data Ma2017;
set cduc;
if cd10_count<1 then delete;
if uc10_count>=1 then delete;
run;
ods pdf file='S:\CMS\CMS synth data\Ma2017.pdf';
Title 'Ma 2017 (PMID:29087396);
        *= 1 ICD-10 K50.0, K50.1 or K50.8 during hospitalization exclude K51.x;
        *Canada
        Validation years: 2011
        Inpatient only
        No minimum follow-up
        Adults Adults (= 18)
        Sensitivity 30-95% Specificity 89-99% NPV 66-99% PPV 67-97%';

proc means data=tepaniuk2015 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=tepaniuk2015;
table sex;
run;
ods pdf close;

data Soh2019;
set cduc;
if cd10_count<1 then delete;
run;

ods pdf file='S:\CMS\CMS synth data\Soh2019.pdf';
Title'Soh 2019 validated 2010-2013
Park 2018 validated 2010-2013
Kim 2015 validated 2006-2012(PMID:30602222);
*= 1 ICD-10 K50.x in inpatient or outpatient setting
AND registered in rare disease database as Crohns disease (RID V130)
*South Korea
Inpatient or outpatient
No minimum follow-up
No age restriction
Sensitivity 94.5-98.3% Specificity 93.5%';

proc means data=tepaniuk2015 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=tepaniuk2015;
table sex;
run;

ods pdf close;
***ICD 9 and 10 case definitions;

data Rezaie2012;
set cduc;
if cd9_count+cd10count<2 then delete;
run;
ods pdf file='S:\CMS\CMS synth data\Rezaie2012.pdf';
Title'Rezaie2012
(PMID:PMC3472911);
= 2 hospitalizations or = 4 physician claims or
=2 ambulatory surgery visits for ICD-9 555.x
or ICD-10 K50.x within 2 years
*Canada
Validation years: 1997-2007
Inpatient or outpatient
No minimum follow-up
No age restriction
Sensitivity 93.5% Specificity 99.1%';

proc means data=Rezaie2012 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=Rezaie2012;
table sex;
run;
ods pdf close;

data Benchimol2014;
set cduc;
if cd9_count+cd10count<2 then delete;
if uc9_count+uc10count<2 then delete;
if age<=18 then delete;
run;

ods pdf file='S:\CMS\CMS synth data\Benchimol2014.pdf';
Title 'Benchimol 2014
(PMID: 24774473);
= 9 ICD-9 555.x or 556.x or ICD-10 K50.x or K51.x.
5/9 of the most recent visits must be for CD
(ICD-9 555.x or ICD-10 K50.x).
All 9 codes must occur within a 4-year period.
*Canada
Validation years: 2001-2006
Inpatient or outpatient
No minimum follow-up
Adults(>=18)
Accuracy 95.6%';

proc means data=Benchimol2014 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=Benchimol2014;
table sex;
run;

ods pdf close;

data Benchimol2009;
set cduc;
if cd9_count+cd10count<2 then delete;
if age>18 then delete;
run;
ods pdf file='S:\CMS\CMS synth data\Benchimol2009.pdf';
Title'Benchimol 2009
(PMID: 19651626);
=7  IBD physician visits: =5 of last 7 coded for CD (555.x, K50.x)
<7 IBD physicians visits: All visits for ICD-9 555.x or ICD-10 K50.x
 All visits within a 3-year period.
*Canada
Validation years: 2001-2005
outpatient
No minimum follow-up
Pediatric<18;
Accuracy 95.6%';
proc means data=Benchimol2009 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;
proc freq data=Benchimol2009;
table sex;
run;
ods pdf close;

*ICD 8 case defintions;

*ods pdf file='S:\CMS\CMS synth data\barton1989.pdf';
title1 'Barton 1989 (PMID:2786488)';
title2 '= 1 ICD-8 563.0 or ICD-9 555.x code during
        hospitalization, United Kingdom
        Validation years: 1968-1983
        Inpatient only
        No minimum follow-up
        Pediatric (= 20)
        PPV 87%';

proc means data=barton1989 n mean median min max;
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: ;*fup_first_cd_dx;
run;

proc freq data=barton1989;
table sex;
run;

ods pdf close;
data barton1989;
set crohns3;
*icd-8 years for the dataset;
if 1995<=year<=2007 then do;
        *make an array to do for all diag codes 1-10;
        array  dgns8 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        do n=1 to 10;
                if substr(dgns8(n),1,4)='5630' then cd=1;
        end;
end;
*icd-9;

data barton1989;
set crohns3;
if 2008<=year<=2010 then do;
array  dgns9 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        do i=1 to 10;
        if substr(dgns9(i),1,3)='555' then cd=1;
        if substr(dgns9(i),1,3)='556' then uc=1;
        end;
end;
*icd-9;
*if 2008<=year<=2010 then do;
*array  dgns9 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        *do i=1 to 10;
        *if substr(dgns9(i),1,3)='555' then cd=1;
        *end;
*end;
*if cd ne 1 then delete;



**variable name in medicare dictionary;
age=(clm_from_dt-el_dob)/365.25; label age='age at any encounter';
run;


*count unique days with cd;

proc sort data=barton1989 NODUPKEY;
by Desynpuf_id CLM_FROM_DT cd uc;

proc sort data=barton1989;
by Desynpuf_id CLM_FROM_DT cd;


data cd (keep = Desynpuf_id cd_count);
set barton1989;
by  desynpuf_id CLM_FROM_DT cd;
where cd=1;
if first.Desynpuf_id then cd_count=0; cd_count+1; *keeps crohn's disease dx only--doesn't count uc dx;
if last.Desynpuf_id then output;
run;


proc freq;
table cd_count;
run;

**count unique days with uc;
proc sort data=barton1989;
by desynpuf_id CLM_FROM_DT uc;


data uc (keep = desynpuf_id uc_count);
set barton1989;
by desynpuf_id CLM_FROM_DT uc;
where uc=1;
if first.Desynpuf_id then uc_count=0; uc_count+1;
if last.Desynpuf_id then output;
run;

proc freq;
table uc_count;
run;


**combine both datasets for unique days of uc and cd;
data &lwork..cduc2(keep=desynpuf_id cd_count uc_count cd_prop ibd_count);
merge uc cd;
by desynpuf_id;
if cd_count=. then cd_count=0;
if uc_count=. then uc_count=0;
ibd_count=cd_count+uc_count;
cd_prop=cd_count/ibd_count;
run;


**  find the average, median, count, min, max for
    cd count, uc count, cd&uc count (ibd), and
    proportion of cd count out of ibd count;

proc means data=&lwork..cduc2 n mean median p25 p75 min max;
var cd_prop cd_count uc_count ibd_count;

run;

*Fonager 1996 (PMID:8658038);
        *= 1 ICD-8 563.01(If 563.19 or 569.04 then exclude);
        *Denmark
        Validation years: 1988-1992
        Inpatient only
        No minimum follow-up
        No age restriction
        Sensitivity 94%;

data fonager1996;
set &lwork..cduc2;
*icd-8 years for the dataset;
if 1995<=year<=2007 then do;
        *make an array to do for all diag codes 1-10;
        array  dgns8 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        do n=1 to 10;
                if dgns8(n)='56301' then cd=1;
                if dgns8(n)=('56319','56904')  then uc=1;
        end;
end;

*count unique days with cd;

proc sort data=Fonager1996 NODUPKEY;
by Desynpuf_id CLM_FROM_DT cd uc;

proc sort data=Fonager1996;
by Desynpuf_id CLM_FROM_DT cd;

data cd (keep = Desynpuf_id cd_count);
set Fonager1996;
by  esynpuf_id CLM_FROM_DT cd;
where cd=1;
if first.Desynpuf_id then cd_count=0; cd_count+1; *keeps crohn's disease dx only--doesn't count uc dx;
if last.Desynpuf_id then output;
run;

proc freq;
table cd_count;
run;

**count unique days with uc;
proc sort data=Fonager1996;
by esynpuf_id CLM_FROM_DT uc;

data uc (keep = esynpuf_id uc_count);
set Fonager1996;
by esynpuf_id CLM_FROM_DT uc;
where uc=1;
if first.Desynpuf_id then uc_count=0; uc_count+1;
if last.Desynpuf_id then output;
run;

proc freq;
table uc_count;
run;

**combine both datasets for unique days of uc and cd;
data &lwork..cduc2(keep=esynpuf_id cd_count uc_count cd_prop ibd_count);
merge uc cd;
by esynpuf_id;
if cd_count=. then cd_count=0;
if uc_count=. then uc_count=0;
ibd_count=cd_count+uc_count;
cd_prop=cd_count/ibd_count;
run;

**find the average, median, count, min, max for cd count,
uc count, cd&uc count (ibd), and proportion of
cd count out of ibd count;

proc means data=&lwork..cduc2 n mean median p25 p75 min max;
var cd_prop cd_count uc_count ibd_count;
run;



***Unique case defintions;

*Lewis 2002 (PMID:12032734?);
        *= 1 OXMIS/Read code 5630CR, 5630C, 5630ER,
           0092LR in primary care records;
        *United Kingdom
        Validation years:
        Primary care only
        No minimum follow-up
        No Age restrictions
        Sensitivity 94%;





*Herrinton 2007 (PMID:1721940);
*= 1 ICD-9 555.x in inpatient or outpatient setting AND
 = 1 dispensing for mesalamine, olsalazine, balsalazide
 from outpatient pharmacy;
*United States
Validation years: 1999-2001
Inpatient or outpatient
No minimum follow-up
No age restriction
PPV 67-86%;

*Ananthakrishnan 2013 (PMID:23451882);
        **= 1 ICD-9 555.x in electronic health record AND
          = 1 mention of 5-aminosalicylate, antibiotic,
           corticosteroid, immunomodulatory, anti-TNF or natalizumab;
        *United States
        Validation years: Not reported
        Inpatient or Outpatient
        No minimum follow-up
        No age restriction
        AUC 0.92;

*Ananthakrishnan 2013 Liao 2015 (PMID:25213079);
        **= 1 ICD-9 555.x in inpatient/outpatient AND
          = 1 mention of 5-aminosalicylate, antibiotic,
          corticosteroid, immunomodulatory, anti-TNF or natalizumab;
        *United States
        Validation years: Not reported
        Inpatient or Outpatient
        No minimum follow-up
        No age restriction
        AUC 0.95 Sensitivity 69% Specificity 97% PPV 98%;



*Jakobsson 2017(PMID:1721940);
*= 1 ICD-7 572.00, 572.09, ICD-8 563.00, ICD-9 555.x, or
  ICD-10 K50.x code in inpatient or outpatient specialty
  visit AND registered at least once in a national IBD registry;
*exclude If ICD-7 572.20, 572.21, ICD-8 563.10,
 569.02, ICD-9 556.x, or ICD-10 K51.x
*Sweden
Validation years=1987-2015
Inpatient or outpatient specialty visit
No minimum follow-up
No age restriction
PPV 90%;

data barton1989;
set &lwork..cduc2;
*icd-7 years for the dataset;
if 1995<=year<=2007 then do;
        *make an array to do for all diag codes 1-10;
        array  dgns7 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        do n=1 to 10;
                if substr(dgns7(S),1,5'57200' then cd=1;
        end;
end;
*icd-8 years for the dataset;
if 1995<=year<=2007 then do;
        *make an array to do for all diag codes 1-10;
        array  dgns8 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        do n=1 to 10;
                if substr(dgns8(n),1,5) in ('56300' '56902') then cd=1;
        end;
end;
*icd-9;
if 2008<=year<=2010 then do;
array  dgns9 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        do i=1 to 10;
        if substr(dgns9(i),1,3)='555' then cd=1;
        end;
end;
if cd ne 1 then delete;
if 2010<=year<=2014 then do;
array  dgns10 (10) ICD9_DGNS_CD_1-ICD9_DGNS_CD_10;
        do i=1 to 10;
        if substr(dgns10(t),1,3)='K50' then cd=1;
        if substr(dgns10(t),1,3)='K51' then uc=1;
        end;
end;




%mend; *** from turn_all_this_off;
