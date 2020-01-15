/********************************************************************
* Job Name: crohns_claim_identify_denom_elig_merge_ndc_product_merge.sas
* Job Desc: Identify how many cases in cohort meet criteria for
*           validated case definitions from literature
* See corresponding manuscript: ENTER WHEN READY
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************/

/********************************************************************
 * INSTRUCTIONS:
 * This program uses publicly available CMS sytnthetic data to
 * illustrate how one can identify the number of cases of
 * Crohn's disease using all of the case definitions associated
 * with validation studies in the literature through MONTH 2019.
 * You can also run the program on any claims data set that uses
 * ICD coding by modifying the variable names in the %let
 * statements
 *
 * You can download the CMS synthetic data and codebooks at
 * https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/index.html
 * We have also downloaded the .SAS and .CSV files here:
 * https://jh.box.com/s/6hkk11tc38cdfju21yc2fzbeqvumocjy
 *
 * This program is divided into various parts that are sequential.
 * Part 0: Field Configuration and settings.
 *         In this section we can set and configure parts of code
 *         that are used from this point on.
 * Part 1: Input of Data
 *         Types of Data: Claims, Demographic
 *         Pt1-A - Repeats for each source
 *         to combine into one output dataset
 *         This sets up the CMS synthetic dataset
 *         for work in this code
 *         Pt1-B - Prepares data after input
 *
 * Part 3: Program that creates each case definition and outputs
 *         tables with the case definitions so that the user can
 *         compare the number of patients identified from their
 *         cohort using each validated case definition.
 * NOTE:   that the program assumes that you are using the correct
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
********************************************************************/

%let synthdata="\\win.ad.jhu.edu\cloud\sddesktop$\CMS\CMS synth data";
%let synthdata="C:\z_data\z_client_jhu\puf1";
libname synth &synthdata;
run;

libname ndcprod "C:\z_data\z_client_jhu\ndc_puf_short_term";

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
%let diag_i9_pfx       = &icd_pfx.9_dgns_cd_ ; /* diagnosis code prefix - specific to i9  */
%let diag_i10_pfx      = &icd_pfx.10_dgns_cd_; /* diagnosis code prefix - specific to i10 */
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
%let elig_st_dt        = coverage_st_dt      ; /* benefit start date - imputed */
%let flag_icd910       = flag_icd910         ; /* flag indicating if claim is i9 or i10 */

%let flag_uc_pfx       = uc_ ;
%let flag_cd_pfx       = cd_ ;
%let flag_uc_i9        = &flag_uc_pfx.9;
%let flag_cd_i9        = &flag_cd_pfx.9;
%let flag_uc_i10       = &flag_uc_pfx.10;
%let flag_cd_i10       = &flag_cd_pfx.10;

%global temp_ds_pat_pharma ;
%let temp_ds_pat_pharma = synth.prescription_sample_1;

%global temp_ds_ndc_cat ;
%let temp_ds_ndc_cat    = ndcprod.Ndc_prod_cats;

%global  prod_ndc          ;
%let     prod_ndc          =productndc     ;
%global  prod_srvc_id       ;
%let     prod_srvc_id       =prod_srvc_id;
%global  med_ndc_pfx       ;
%let     med_ndc_pfx       = ttl_ ; /** prefix analyst used for med, product pharma flags **/

/*** part 1 section - BEG - START ***/
/*** part 1 section - BEG - START ***/
/*** part 1 section - BEG - START ***/


/*** input claims ***/
%let in_data_clm_a = &synth_lib..carrier_sample_1a   ;
%let in_data_clm_b = &synth_lib..carrier_sample_1b   ;
%let in_data_clm_c = &synth_lib..inpatient_sample_1  ;
%let in_data_clm_d = &synth_lib..outpatient_sample_1 ;
%let tmp_ds_claims = &lwork..diag;

/* Make 1 dataset with all of the patient encounters recorded in ICD codes */

data &tmp_ds_claims (keep = &pat_id
                            &clm_beg_dt
                            &clm_end_dt
                            &icd_pfx.:
                            &hcpcs_pfx.:
                            );
    set
    &in_data_clm_a
    &in_data_clm_b
    &in_data_clm_c (drop = &hcpcs_pfx.14 - &hcpcs_pfx.44)
    &in_data_clm_d
    ;
run;


/** input demog **/
/* Bring in enrollment, demographics if they are in another file */
/* Some case definitions take into account time under follow-up
   before and after Crohn's disease diagnosis.  Make Medicare
   coverage start and end variables from the beneficiary
   summary file data. The beneficiary summary data is 1 record
   per person and a person contributes to each year file that
   they were a Medicare beneficiary.  So we are going to make
   a Medicare coverage start and end variable for the
   entire 2008-2010 period in a 1 record per person dataset to
   merge with our 1 record per person Crohn's count dataset
   down below.  We could bring the 1 record per person coverage
   data to our claims file (crohns1 which is 1 record per
   person/clm_id/clm_dt) but we are choosing to wait until
   we have made a 1 record per person encounter summary file
*/

%macro mbsf(in=, out=, covstart=);

data &out (keep=  &pat_id
                  &pat_dob
                  &pat_dod
                  &pat_race
                  &pat_gender
                  &elig_st_dt);
    set &in;
    &elig_st_dt ="01jan&covstart"d;
    format &elig_st_dt  yymmdd10.;
run;

proc sort data=&out nodupkey;
    by &pat_id;
run;

%mend;


%let inds_bene_2008 =&synth_lib..beneficiary_2008_sample_1 ;
%let inds_bene_2009 =&synth_lib..beneficiary_2009_sample_1 ;
%let inds_bene_2010 =&synth_lib..beneficiary_2010_sample_1 ;

%mbsf(in=&inds_bene_2008, out=&lwork..bene2008, covstart=2008);
%mbsf(in=&inds_bene_2009, out=&lwork..bene2009, covstart=2009);
%mbsf(in=&inds_bene_2010, out=&lwork..bene2010, covstart=2010);

data &lwork..mbsf2008_2010;
    update &lwork..bene2010
           &lwork..bene2009;
    by &pat_id;
run;

data &lwork..mbsf2008_2010;
    update &lwork..mbsf2008_2010
           &lwork..bene2008;
    by &pat_id;
    covend      = max("31dec&max_year"d, &pat_dod );
    label covend     = 'end of medicare coverage';
    format covend yymmdd10.;
run;





/*** input meds ***/
/* Medications */
/** this section requires that an analyst has prepared the
    scan NDC data before this section can run
    note that older and or existing NDC scanned data
    may be included unless you the analyst omit or drop
    ndc "ttl_'medication'" fields, vars **/

data &lwork..temp_pat_pharm;
    set &temp_ds_pat_pharma (keep= &pat_id &prod_srvc_id);
run;

data &lwork..temp_ndc_cat (keep=&prod_srvc_id
                                &med_ndc_pfx.:   /** keeping all fields with ttl_ prefix **/
                                );
    set &temp_ds_ndc_cat;
        &prod_srvc_id=0;
    format &prod_srvc_id 10.;
    &prod_srvc_id= &prod_ndc *1 ;
    drop &prod_ndc;
    *** uncomment to drop specific ndc product fields ;
    **  example:  drop  ttl_some_med_name ;
    **  note in this code we control prefix with: med_ndc_pfx ;
run;

proc sort data=&lwork..temp_pat_pharm nodupkey;
by &prod_srvc_id &pat_id;
run;

proc summary data=&lwork..temp_ndc_cat nway;
class &prod_srvc_id;
var &med_ndc_pfx.:;
output out=&lwork..temp_ndc_cat (drop=_type_ _freq_)
sum=;
run;

/*** zt testing and evaluating only on antibiotics - low match to other meds **/
data &lwork..tmp_pat_on_meds (keep= &pat_id ttl_anti: /** &med_ndc_pfx.: **/ );
    merge &lwork..temp_pat_pharm (in=a)
          &lwork..temp_ndc_cat   (in=b);
          by &prod_srvc_id;
          if a and b;
run;

proc sort data= &lwork..tmp_pat_on_meds   nodupkey;
by &pat_id &med_ndc_pfx.:;
run;

/*** part 1 section - END ***/
/*** part 1 section - END ***/
/*** part 1 section - END ***/




/*** part 2 section - BEG - Start ***/
/*** part 2 section - BEG - Start ***/
/*** part 2 section - BEG - Start ***/

/*** prep claims ***/
%let tmp_ds_crohns = &lwork..crohns1 ;

data &tmp_ds_crohns  (drop= n i j);
    set
    &tmp_ds_claims
    ;

    length &diag_i10_pfx.&diag_min  - &diag_i10_pfx.&diag_max  $5.;

    /* Create year of diagnosis from the claim date,
       year4 is a special format for the cms synthetic data*/
        &enc_year = put(&clm_beg_dt ,year4.);

    /* Make a few fake ICD-10 codes for CD and UC so we
       can check the ICD 10 code
       since the dataset is 2008-2010 (pre icd-10) */
    /* create icd 10 variable and set to missing */

    array new(&diag_max) &diag_i10_pfx.&diag_min  - &diag_i10_pfx.&diag_max ;
            DO n = &diag_min TO &diag_max;
                    new(n)=' ';
    end;
    array  dx9  (&diag_max)  &diag_i9_pfx.&diag_min  - &diag_i9_pfx.&diag_max ;
    array  dx10 (&diag_max)  &diag_i10_pfx.&diag_min - &diag_i10_pfx.&diag_max;
       do i=&diag_min to &diag_max;
          if substr(dx9(i),1,3)='250'  then do;
               do j=&diag_min to &diag_max;
                  dx10(j)='K500';
                  end;
                  end;
          if substr(dx9(i),1,3)='401' then do;
               do j=&diag_min to &diag_max;
                  dx10(j)='K510';
                  end;
                  end;
    end;

    /* Indicate if data is icd 9 or 10 for date based on year
       (will have all icd-9 because years are 2008-2010 */
    &flag_icd910=0;
    if &clm_beg_dt  le &icd9_10_cutoff_dt then do;
        &flag_icd910=9;
    end;
    if &clm_beg_dt  gt &icd9_10_cutoff_dt then do;
        &flag_icd910=10;
    end;
    label &flag_icd910 ='indicator if dx code is 9 or 10 based on date of claim';
run;



/* count icd9 & icd10 codes */
data &tmp_ds_crohns._count1 (keep = &pat_id
                                    &clm_beg_dt
                                    &flag_uc_i9
                                    &flag_cd_i9
                                    &flag_uc_i10
                                    &flag_cd_i10
                                    );
    set
    &tmp_ds_crohns
    ;

    if &min_year <= &enc_year <= &max_year then do;
    array  dgns9 (&diag_max) &diag_i9_pfx.&diag_min  - &diag_i9_pfx.&diag_max ;
            do i=&diag_min to &diag_max;
            if substr(dgns9(i),1,3)='555' then &flag_cd_i9=1;
            if substr(dgns9(i),1,3)='556' then &flag_uc_i9=1;
            end;
    end;

    if &min_year <= &enc_year <= &max_year then do;
    array  dgns10 (&diag_max) &diag_i10_pfx.&diag_min  - &diag_i10_pfx.&diag_max ;
            do t=&diag_min to &diag_max;
            if substr(dgns10(t),1,3)='K50' then &flag_cd_i10=1;
            if substr(dgns10(t),1,3)='K51' then &flag_uc_i10=1;
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

proc sort data=&tmp_ds_crohns._count1    NODUPKEY;
by &pat_id  &clm_beg_dt &flag_uc_i9  &flag_cd_i9  &flag_uc_i10 &flag_cd_i10 ;
run;

proc sort data=&tmp_ds_crohns._count1;
by &pat_id  &clm_beg_dt;
run;


data  &tmp_ds_crohns._count1 ;
    merge  &tmp_ds_crohns._count1   (in=a)
           &lwork..tmp_pat_on_meds  (in=b);
           by &pat_id;
           if a;
run;

proc freq data=&tmp_ds_crohns._count1 ;
table &med_ndc_pfx.:;
run;