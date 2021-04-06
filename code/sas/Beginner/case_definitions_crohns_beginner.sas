

/********************************************************************
	* Job Name: jhu_case_definitions_crohns_beginner.sas
	* Job Desc: Identify Crohn's disease cases using claims data
	* See corresponding manuscript (Table 2): ENTER WHEN READY OK
	********************************************************************/
	
	/********************************************************************
	* INSTRUCTIONS:
	* This program uses publicly available CMS synthetic data to
	* illustrate how one can identify the number of cases of
	* Crohn's disease using all of the case definitions associated
	* with validation studies in the literature through MONTH 2020.
	* You can also run the program on any claims data set that uses
	* ICD coding by modifying the variable names to match your dataset.
	
	* You can download the CMS synthetic data and codebooks at
	* https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/index.html
	* https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/DESample01
	* We have also downloaded the .SAS and .CSV files here:
	* https://livejohnshopkins-my.sharepoint.com/:f:/g/personal/shutfle1_jh_edu/En0Ka4-okBFKm-lFa3ck-OMBlPbAu_Nrps7ZyfXdPnDGbw

	
	* This program is divided into parts that you run sequentially.
	* If you have your own dataset AND you understand SAS, you can start at Part 2.
	
	* Part 1: Set up the CMS synthetic datasets

	* Part 2: Insert %let statements for use on any dataset configured like 
          	the CMS Synthetic datasets created in Part 1. At the end of Part 2,
	  	you will have a 1 record per person analytic file.  
	
	* Part 3: This program creates case definitions for Crohn's disease
		based on the literature as published in our manuscript (line 6).
		This part of the code makes a table for each case definition.
		You can compare the number of patients identified from your
	        cohort using each validated case definition.
	* NOTE:   The program assumes that you are using the correct
	*         types of datsets (inpatient/outpatient) based on the
	*         characteristics of the cohort used to calculate the
	*         diagnostic accuracy in each validation study.
	*         We have added these characteristics to the output,
	*         but it is up to the user to confirm that they are
	*         using the validated definition appropriately.

	*********************************************************************/
	
	/********************************************************************
	* Need Help with SAS?
	* If you have questions about using SAS or its syntax, we suggest:
	*    https://www.sas.com/en_us/learn/academic-programs/resources/free-sas-e-learning.html
	*    https://stats.idre.ucla.edu/sas/
	*    https://www.lexjansen.com/
	* Ask questions in the SAS community: https://communities.sas.com/
	*   Before posting a new question in the SAS community, take a look
	*	if someone has already asked/answer your questions 
	*	& at how others ask questions before posting your own (do not screenshot,
	* 	whatever you post should be copy-paste-able!)
	* This program was created in SAS Enterprise. SAS 9.4 is known to have
		difficulties with the death dates.  Use Enterprise if possible.
	********************************************************************/

	/*** part 1 section - BEG -- START ***/
	/*** part 1 section - BEG -- START ***/
	/*** part 1 section - BEG -- START ***/
/****Part 1: Set up CMS Synthetic data***/

/* Identify where you downloaded synthetic data onto your machine  */
/** You need to EDIT the information inside the quotes!!!!!!!!!!**/
libname synth "C:\Users\shutfle1\OneDrive - Johns Hopkins\Synthetic datasets";
run;

/* First you need to examine your datasets.  Read the codebook then examine your SAS files.
	Identify variables (proc contents), look at data directly (proc print), 
	examine uniqely identified variables (proc sort no dupkey),
	look at missing numeric variables (proc means nmiss).
	These steps should be done for all datasets at the start of every project.
	Here we give an example of checking one of the datasets used to set up the synthetic data */
/* If you don't understand, you should review the SAS resources */

proc contents data=synth.carrier_sample_1a;
run;
proc print data=synth.carrier_sample_1a (obs=20);
run;
/**Check for duplicates in the datasets **/
proc sort data=synth.carrier_sample_1a NODUPKEY out= work.try dupout=dupes;
by desynpuf_id clm_id clm_thru_dt;
run;
proc means nmiss data=synth.carrier_sample_1a; run;


/*We are going to read in the claims, enrollment and medications files
	--these are all of the files we will need for our analysis**/

/* Concatenate (make 1 dataset) of all claims files: 
	carrier, inpatient, and outpatient datasets */
/* note the obs----this limits a dataset to the number of observations specified--do this to make a program run 
			faster while you are testing it--remember to remove the obs limit for final */
data work.diag;
set
synth.carrier_sample_1a /*(obs=200000)*/
synth.carrier_sample_1b /*(obs=200000)*/
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

    if icd9_dgns_cd_1='4019' then icd10_dgns_cd_1='K510';
    if icd9_dgns_cd_2='4019' then icd10_dgns_cd_2='K510';
	if icd9_dgns_cd_3='4019' then icd10_dgns_cd_3='K510';
	if icd9_dgns_cd_4='4019' then icd10_dgns_cd_4='K510';
	if icd9_dgns_cd_5='4019' then icd10_dgns_cd_5='K510';
	if icd9_dgns_cd_6='4019' then icd10_dgns_cd_6='K510';
	if icd9_dgns_cd_7='4019' then icd10_dgns_cd_7='K510';
	if icd9_dgns_cd_8='4019' then icd10_dgns_cd_8='K510';
	if icd9_dgns_cd_9='4019' then icd10_dgns_cd_9='K510';
	if icd9_dgns_cd_10='4019' then icd10_dgns_cd_10='K510';
run;
proc freq data=claims;
table year;
run;
proc freq data=claims order= freq;
table icd9_dgns_cd_1 icd10_dgns_cd_1;
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

	%macro mbsf(in=, out=, covstart1=, covstart2=);
	
	data &out (keep=  desynpuf_id
	                  bene_birth_dt
					  bene_death_dt
	                  bene_race_cd
	                  bene_sex_ident_cd
	                  &covstart1);
	set &in;
	&covstart1=&covstart2; *covstart1 is the variable name, covstart2 is the date that we are assigning to start of coverage;
	format &covstart1 date9.;
	run;
	
	proc sort data=&out nodupkey;
	by desynpuf_id;
	run;
	%mend; *every macro must have a mend, then the statements below to call the macro with the variables you want;
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
*label Crohn's drugs of interest;
/*make labels for drugs of interest based on pharm classes*/
		if pharm_classes = "AMINOSALICYLATE [EPC],AMINOSALICYLIC ACIDS [CS]"
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
if drug_5asa=. and drug_steroids=. and drug_immunomodulator=. and drug_biologic=. then delete; *if you want to keep all drugs then star out this step;
run;
proc freq data=pde_ndc; table drug: ; run;
	
	/*** part 1 section - END ***/
	/*** part 1 section - END ***/
	/*** part 1 section - END ***/
	
	
	
	
	/*** part 2 section - BEG - Start ***/
	/*** part 2 section - BEG - Start ***/
	/*** part 2 section - BEG - Start ***/
/*take the datasets that we made/refined above and refmine them further to a 1 record per person analytic file*/
/*If you are not using the CMS synthetic data, set up your variables and variable formatting to match
	your dataset*/


/*merge claims with beneficiary info*/
proc sort data=	claims; by desynpuf_id;
proc sort data= mbsf2008_2010; by desynpuf_id;
run;

data claims2;
merge 
claims (in=a) 
mbsf2008_2010 (in=b);
by desynpuf_id;
if a and b;
run; *the number of rows here should match the rows in claims;


/*identify claims for CD and UC*/
	data crohns_count1 (keep = desynpuf_id
									bene_birth_dt 
									bene_sex_ident_cd 
									bene_race_cd  
									covstart
									covend
                                    clm_from_dt
                                    uc_9
                                    cd_9
									ibd_9
                                    uc_10
                                    cd_10
									ibd_10
                                    );
	set
	claims2;* (obs=20000);
	/* Create year of diagnosis from the claim date,
	   year4 is a special format for the cms synthetic data*/
	    year = put(clm_from_dt ,year4.);
/*delete claims outside of time period of interest*/
	if year<2008 then delete;
	if year>2010 then delete;
/* Indicate if data is icd 9 or 10 for date based on year
	       (will have all icd-9 because years are 2008-2010*/
	        if clm_from_dt  le '31oct2015'd then do;
	        flag_icd910=9;
	        end;
	        if clm_from_dt  gt '31oct2015'd then do;
	        flag_icd910=10;
	        end;
	        label flag_icd910='indicator if dx code is 9 or 10 based on date of claim';
/*identify claims for crohn and ulcerative colitis--only keep those claims*/
/*need 1 array for ICD-9 and 1 array for ICD-10*/
    if 2008 <= year <= 2010 then do; *set to years you want icd-9 codes applied;
    array  dgns9 (10) icd9_dgns_cd_1  - icd9_dgns_cd_10 ; *this dataset only has 10 dx codes--others may have more/less;
            do i=1 to 10;
            if substr(dgns9(i),1,3)='555' then cd_9=1;
            if substr(dgns9(i),1,3)='556' then uc_9=1;
			if substr(dgns9(i),1,3) in('555','556') then ibd_9=1;
            end;
    end;

    if 2008 <= year <= 2010 then do; *set to years want icd-10 dx codes applied;
    array  dgns10 (10) icd10_dgns_cd_1  - icd10_dgns_cd_10 ;
            do t=1 to 10;
            if substr(dgns10(t),1,3)='K50' then cd_10=1;
            if substr(dgns10(t),1,3)='K51' then uc_10=1;
			if substr(dgns10(t),1,3) in('K50','K51') then ibd_10=1;
            end;
    end;

    if uc_9  = . and
       cd_9  = . and
       uc_10 = . and
       cd_10 = .
       then delete;
run; *there should be 7,568 if did not limit obs above;

	/**  We want to count the number of visits/encounters for CD / UC.
	     We are going to count up the encounters for cd in icd-9 and
	     icd-10 and for uc in icd-9 and icd-10.  We are counting up
	     UC because some case definitions allow patients to have
	     encounters for UC despite actually having Crohn's disease.
	     If you have questions about using counts with
	     a by statement check out:
	     https://blogs.sas.com/content/iml/2018/02/26/how-to-use-first-variable-and-last-variable-in-a-by-group-analysis-in-sas.html
	     */
	
%macro counts(code= , code_count= , date_code= , age_code=, label1= , label2=, label3=);

proc sort data=crohns_count1    NODUPKEY;
by desynpuf_id  clm_from_dt uc_9  cd_9  uc_10 cd_10 ;
run;

data &code (keep = 					desynpuf_id 
					&date_code 
					&code_count 
					&age_code
									bene_birth_dt 
									bene_sex_ident_cd 
									bene_race_cd  
									covstart
									covend);
set
crohns_count1;
by  desynpuf_id clm_from_dt;
where &code=1; 
if first.desynpuf_id then do;
    &date_code = clm_from_dt ; /* if the first. statement was not used then this variable would label every claim_dt as the first cd/uc claim date */
	&age_code=(clm_from_dt-bene_birth_dt )/365.25;
    &code_count=0;
end;
 	&code_count+1;			/* the counter +1 must be after end so the counter applies beyond first.variable */

 if last.desynpuf_id then output;

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

%counts(code =	cd_9 , code_count = cd9_count ,  
				date_code = cd9_date_first  , age_code=cd9_age_first ,
	label1 = 'Number of Crohns encounters in ICD-9', 
	Label2 = 'Date of first CD diagnosis in ICD-9',
	label3='Age of first CD diagnosis in ICD-9');
%counts(code =	uc_9 , code_count = uc9_count ,  
				date_code = uc9_date_first  , age_code=uc9_age_first ,
	label1 = 'Number of ulcerative colitis encounters in Icd-9', 
	Label2 = 'Date of first uc diagnosis in Icd-9',
	label3='Age of first uc diagnosis in Icd-9');
%counts(code =	ibd_9 , code_count = ibd9_count ,  
				date_code = ibd9_date_first  , age_code=ibd9_age_first ,
	label1 = 'Number of inflammatory bowel disease encounters in Icd-9', 
	Label2 = 'Date of first ibd diagnosis in Icd-9',
	label3='Age of first ibd diagnosis in Icd-9');
%counts(code =	cd_10 , code_count = cd10_count ,  
				date_code = cd10_date_first  , age_code=cd10_age_first ,
	label1 = 'Number of Crohns encounters in ICD-10', 
	Label2 = 'Date of first CD diagnosis in ICD-10',
	label3='Age of first CD diagnosis in ICD-10');
%counts(code =	uc_10 , code_count = uc10_count ,  
				date_code = uc10_date_first  , age_code=uc10_age_first ,
	label1 = 'Number of ulcerative colitis encounters in Icd-10', 
	Label2 = 'Date of first uc diagnosis in Icd-10',
	label3='Age of first uc diagnosis in Icd-10');
%counts(code =	ibd_10 , code_count = ibd10_count ,  
				date_code = ibd10_date_first  , age_code=ibd10_age_first ,
	label1 = 'Number of inflammatory bowel disease encounters in Icd-10', 
	Label2 = 'Date of first ibd diagnosis in Icd-10',
	label3='Age of first ibd diagnosis in Icd-10');


/**combine datasets for unique days of uc9 and cd9*/
data cduc (keep=		desynpuf_id 
						bene_birth_dt 
						bene_sex_ident_cd 
						bene_race_cd  
						covstart
						covend 
						cd9: uc9: cd10: uc10: ibd9: ibd10:);
/**keep statement note: anything starting with the variable after the colon will be included*/
    merge
    cd_9
    uc_9
	ibd_9
    cd_10
    uc_10
	ibd_10;
    by desynpuf_id;
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
cd_age_dx   = (cd_date_first - bene_birth_dt )/365.25;
ibd_age_dx  = (ibd_date_first - bene_birth_dt )/365.25;
fuptoCD    = cd_date_first    - covstart ; 
fupafterCD = covend     - cd_date_first ; 
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
proc means data=cduc
      n mean median p25 p75 min max;
      var cd9: uc9: cd10: uc10: ibd9: ibd10:;
run;

/*Now that we have identified our 1 record per person IBD cohort, let's count IBD drug use*/
	
%macro counts(code= , code_count= , date_code= , age_code=, label1= , label2=, label3=);

proc sort data=pde_ndc    NODUPKEY;
by desynpuf_id  srvc_dt ndc drug:;
run;

data &code (keep = 	desynpuf_id 
					&date_code 
					&code_count );
set
pde_ndc;
by  desynpuf_id srvc_dt;
where &code=1; 
if first.desynpuf_id then do;
    &date_code = srvc_dt; /* if the first. statement was not used then this variable would label every claim_dt as the first cd/uc claim date */
    &code_count=0;
end;
 	&code_count+1;			/* the counter +1 must be after end so the counter applies beyond first.variable */

 if last.desynpuf_id then output;

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
*%counts(code =	drug_antibiotics, code_count = drug_antibiotics_count ,  
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
	merge drug_biologic /*drug_antibiotics*/ drug_immunomodulator drug_steroids drug_5asa; 
	by desynpuf_id;
	run;
/*make sure there is only 1 record per person (no dupes)*/
	proc sort data=drugs nodupkey out=try; by desynpuf_id; run;

/*merge drug info with the IBD info*/
proc sort data=drugs; by desynpuf_id;
proc sort data=cduc; by desynpuf_id;
run;

data cduc2;
merge cduc (in=a)
drugs (in=b);
by desynpuf_id;
if a;
if drug_biologic_count=. then drug_biologic_count=0;
if drug_immunomodulator_count=. then drug_immunomodulator_count=0;
if drug_steroids_count=. then drug_steroids_count=0;
if drug_5asa_count=. then drug_5asa_count=0;
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
cduc2
;
if cd9_count  <   1 then delete;
if uc9_count  >=  1 then delete;
*although not specified in validation study, delete those without a first cd diagnosis date;
if cd9_date_first=. then delete;
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
var cd9: uc9: cd10: uc10: ibd9: ibd10: covstart
									covend;
run;

proc freq data=work.DiDomenicantonio2014;
table bene_sex_ident_cd bene_race_cd   drug:;
run;

data Herrinton2007;
set cduc2;
if cd9_count<1 then delete;
*although not specified in validation study, delete those without a first cd diagnosis date;
if cd9_date_first=. then delete;
*calculate minimum cd date from icd-9 and 10;
cd_date_first=min(cd9_date_first, cd10_date_first);
*calculate age at first cd;
age_cd_dx=min(cd9_age_first, cd10_age_first);
/*add duration of followup based on cd date first and end of follow-up variables*/
cd_fup=covend-cd_date_first;
label cd_fup='time between cd diagnosis and end of follow-up';
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
var age_cd_dx cd9: uc9: cd10: uc10: ibd9: ibd10: cd_fup;
run;

proc freq data=Herrinton2007;
table bene_sex_ident_cd bene_race_cd   drug:;
run;


