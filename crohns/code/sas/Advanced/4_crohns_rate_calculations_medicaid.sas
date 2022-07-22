/********************************************************************
* Job Name: 4_crohns_rate_calculations_medicaid.sas
* Job Desc: Create inclusion/exclusion criteria for Crohn's cohort
		THEN merge Medicaid denominator data in with the Crohn's disease
		numerator and calculate rates
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab
********************************************************************/

/********************************************************************
* job LET/Macro vars have been relocated into specific sections
* to enable better control of input, output of Data and Fields/Vars
********************************************************************/

/*** libname prefix alias assignments ***/
%global lwork ltemp shlib                    ;
%let  lwork    = work                             ;
%let  ltemp    = temp                             ;
%let  shlib    = pl052399                         ;

/** pat_id must be set and configured here **/
%global pat_id ;
%let pat_id            = bene_id  state_cd msis_id      ;

/** DESCRIPTION OF NAMING CONVENTION USED IN THIS CODE  **/
/** denom/den - the patient denom/patient summary  **/
/** num/claim - the patient claim(s) with disease  **/
/** mrg       - data that has been merged               **/
/** pop       - data at final stage of use - 
                still at patient event level/detail **/
/** sum       - data that is summarized - grouped to many
                patient events per classification vars  **/

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_crc_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										crc stands for crohns rate calculation (Not colorectal cancer)***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** MAX stands for Medicaid MAX -
										  prefix for long term proj data
                                          leave the trailing underscore ***/

%global temp_inds_denom; /*inds standrds for input dataset*/
%global temp_inds_num  ;
/** source tables required for code to work  -need the full Medicaid denominator and CD cohort
		to calculate rates**/
%let temp_inds_denom   = &shlib..&proj_ds_pfx.denom_2010_19;
%let temp_inds_num     = &shlib..&proj_ds_pfx.cd_cohort_2010_19;

/** final output dataset--permanente file --1 record per person PRIOR to CD exclusions**/
%global final_num_denom ;
%let final_num_denom   = &shlib..&proj_ds_pfx.cd_rate_num_denom19;

/** create temporary file names **/
%let tmp_out_fnl_all   = &lwork..&temp_ds_pfx.table1 ;
%let fnl_denom       = &lwork..&temp_ds_pfx.dn_pop ;
%let temp_ds_num       = &lwork..&temp_ds_pfx.cd_num ;
%let temp_ds_mrg       = &lwork..&temp_ds_pfx.dn_mrg ;
%let fnl_denom_sum   = &lwork..&temp_ds_pfx.dn_pop_sum;

/*info coming from 3_ file about CD/UC only*/
%let clm_year          = cd_first_yr   ;
%let clm_gender        = cd_first_gender ;
%let clm_age           = cd_first_age    ;
%let clm_race          = cd_first_race   ;
%let clm_state         = cd_first_clm_state  ;
%let clm_place         = cd_first_plc_of_srvc_cd;
%let clm_county        = el_rsdnc_cnty_cd_ltst_cd; *because Medicaid doesn't include claim county, use MBSF;
%let clm_zip           = el_rsdnc_zip_cd_ltst_cd; *because Medicaid doesn't include claim zip, use MBSF;
%let clm_uc_cnt        = uc_count      ;
%let clm_cd_cnt        = cd_count      ;
%let clm_ibd_cnt       = ibd_count     ;
%let clm_cd_prop       = cd_prop       ;

/*info coming from 1_ person summary file: All Medicaid*/
%let den_year_first    = den_year_first ;
%let den_gender        = den_gender    ;
%let den_race          = den_race_eth_cd   ;
%let den_state         = den_state_cd  ;
%let den_place         = den_place     ;
%let den_zip           = den_zip       ;
%let den_county        = den_county    ;
%let den_zip_pfx       = el_rsdnc_zip_cd_ltst_  ;
%let den_county_pfx    = el_rsdnc_cnty_cd_ltst_ ;
%let den_year_pfx      = den_year_     ;
%let den_elig_pop      = den_elig_pop  ;
%let den_ttl_pop       = den_ttl_pop   ;

	/** save denom all medicaid data to local copy instead of working from permanent file  **/
	proc sort data=&shlib..&proj_ds_pfx.denom_2010_19 NODUPKEY
	           out=denom ;
	by &pat_id;
	run;
	proc contents data=&shlib..&proj_ds_pfx.denom_2010_19; run;

	/** source num IBD pat data to local copy instead of working from permanent file **/
	proc sort data=&shlib..&proj_ds_pfx.cd_cohort_2010_19 NODUPKEY
	           out=num ;
	by &pat_id;
	run;
	proc contents data=&shlib..&proj_ds_pfx.cd_cohort_2010_19; run;
	proc freq data=num; table cd_first_yr start_yr cd_inc_year: cd_prev_year: den_year:; run;
	*those with uc/cd will have missing for first year for other that they don't meet criteria for;
	*basd on the way that max is set up, there are none with cd first year in 2012 but there are
		with incidence so use the cd_inc_year to look at incident by year;
	*849,014;

	/** make sure denom/num files are only 1 record per person--if there are records deleted
			then STOP there is a problem with the input files---go back and fix**/

/*** end of bring data ***/

/*start of matching up numerator and denominator and applying excluisons*/
/** merge cd info (num) and all medicaid info (denom)
    info into a single file to make our analytic cohort **/

/** delete those with insufficient Medicaid eligibility **/
/** delete CD patients that did not link to the denom file (on_denom) **/
/** drop variables that don't need or are that don't relate to 15 day eligibility**/
*use to make IBD makeflowchart--then make same exclusions to num&denom;
data flowchart; set num;
	where ibd_count>=1;
	where cd_count>=1;
	where cd_count>=2;
		if on_denom ne 1 then delete;
		if elig_month_flag =. then delete;
	    if den_gender notin ('M','F') then delete;
	    if den_gender='U' then delete;
	    if den_age   =.   then delete; 
	    if den_age   <0   then delete;
	    if den_age   >105 then delete;
		if elig_start_dt=. then delete;
		if den_state_cd = ' ' then delete; 
run;

data base_cohort (drop = new_den_race_eth_cd);
    merge
    denom /*(drop = el_max_elgblty_cd_ltst_2: el_ss_elgblty_cd_ltst_2: den_race_2 - den_race_5
					den_year_:)*/
    num	  /*(drop = cd_last: uc_last: )*/
    ;
    by &pat_id;
	/* delete those who never have a single month that meets the
     15 day eligibility criteria  (some of them have
     days > 15 but it's spread out over multiple months */
  if elig_month_flag =. then delete;
  *if on_denom ne 1 then delete; *on_denom is for CD only--do not exclude from base cohort;
  *make race categories across max and taf--make max match taf;
		if start_yr<2015 then do;
			if den_race_eth_cd in(0,9,.) then den_race_eth_cd=9;
			if den_race_eth_cd=3 then do; new_den_race_eth_cd=4; den_race_eth_cd=.; end;
			if den_race_eth_cd=4 then do; new_den_race_eth_cd=3; den_race_eth_cd=.; end;
			if den_race_eth_cd=6 then do; new_den_race_eth_cd=5; den_race_eth_cd=.; end;
			if den_race_eth_cd=8 then den_race_eth_cd=6;
			if den_race_eth_cd in(5,7) then den_race_eth_cd=7;
		 	if el_max_elgblty_cd_ltst in('11','14','16','17','24','31','34','35') then do; elig_income=1; elig_grp=1;end;
			if el_max_elgblty_cd_ltst in('12','15','22','32','42','52') then do; elig_dsblty=1;  elig_grp=2;end;
			if elig_income=. and elig_dsblty=. then do; elig_other=1;  elig_grp=3; end;
		end;
		if start_yr>=2015 then do;
			if den_race_eth_cd in(0,8,9,.) then den_race_eth_cd=9;
			if /*ELGBLTY_GRP_CD_LTST*/el_max_elgblty_cd_ltst 
				in('04','05','06','07','08','09','11','13','17','18','25','28','29','30','31','33','35','37','38','47','48','49','61','62','63','64','65','67','68','70','72','73','74','75') 
				then do; elig_income=1; elig_grp=1;end;
			if el_max_elgblty_cd_ltst 
				in('12','15','16','19','20','21','22','23','24','39','42','45','50','51','52','53','54','55','56','59','60','69') 
				then do; elig_dsblty=1;  elig_grp=2;end;
			if elig_income=. and elig_dsblty=. then do; elig_other=1;  elig_grp=3; end;
		end;
		if den_race_eth_cd=. then do; den_race_eth_cd=new_den_race_eth_cd; end;
		*if den_race_eth_cd notin('1','2') then den_race_eth_cd=9;
		*set negative dates for crohn's;
		if fup_after_cd<=0 then fup_after_cd=0.001;
		if fup_b4_cd   <=0 then fup_b4_cd   =0.001; 
run;
proc contents data=base_cohort; run;

/**  create flowchart of exclusion criteria
     all exclusion criteria for cohort
    (CD and comparison/numerator & denominator)
     MUST occur at same time/same data steps **/

/** delete missing sex **/
data exclude1;
    set
    base_cohort;
    if den_gender notin ('M','F') then delete;
    if den_gender='U' then delete;
	if den_gender='F' then female=1;
	if den_gender='M' then female=0;
run;
proc freq data=exclude1; table female*den_gender; run;

/** delete missing age **/
data exclude2;
    set
    exclude1;
    if den_age   =.   then delete; *824,469 missing DOB and missing midpoint age;
    if den_age   <0   then delete;
    if den_age   >105 then delete;
    /** turn continuous age into category **/
    if 0  <= den_age <= 5   then den_age_cat = 05   ;
    if 5  <  den_age <= 10  then den_age_cat = 0510  ;
    if 10 <  den_age <= 20  then den_age_cat = 1020 ;
    if 20 <  den_age <= 30  then den_age_cat = 2030 ;
    if 30 <  den_age <= 40  then den_age_cat = 3040 ;
    if 40 <  den_age <= 50  then den_age_cat = 4050 ;
    if 50 <  den_age <= 60  then den_age_cat = 5060 ;
    if 60 <  den_age <= 70  then den_age_cat = 6070 ;
    if 70 <  den_age <= 80  then den_age_cat = 7080 ;
    if 80 <  den_age <= 105 then den_age_cat = 80105;
/*if age categories at incidence and prevalence are important,
	need to calculate the age at midpoint of each year for everyone
	and use that in the age category*/
run;
proc freq data=exclude2; table den_age_cat; run;

/** delete if missing Medicaid eligibility date (see above when excluded those
		with 0 months with at least 15 days**/
data exclude3;
    set
    exclude2;
    if elig_start_dt=. then delete;
run;
/* Delete those with missing state
---Be careful--for most studies you do NOT want to do this!!!**/
data exclude4;
    set
    exclude3;
    if den_state_cd = ' ' then delete; 
run;

/*save permanent version of this dataset for easier editing of CD exclusions*/
data &final_num_denom; set exclude4; 
*make var that combines identifiers for first. counting;
bene_msis_st_id=catx('|',bene_id,msis_id, state_cd);
*below is the exact match to the CD exclusions--none should be excluded if excludes above ran as expected;
		*if on_denom ne 1 then delete;
		if elig_month_flag =. then delete;
	    if den_gender notin ('M','F') then delete;
	    if den_gender='U' then delete;
	    if den_age   =.   then delete; 
	    if den_age   <0   then delete;
	    if den_age   >105 then delete;
		if elig_start_dt=. then delete;
		if den_state_cd = ' ' then delete; 
	*set indicator of crohn's disease;
	if cd_count  >=1 then cd_status =1;
    if ibd_count >=1 and  cd_count  <1 then cd_status=0; /*this labels UC as non-CD*/
    if cd_count  =.  then cd_status =0;
    label cd_status='indicator if have cd or not--use CD prevalent or incident for rate calcs, NOT this variable';
run;*187,417,009 2010-2019;
*this dataset shares same name as the version with all of the drug use, other characteristics below
	after running the code without restriction to CD and with elig_start_dt instead of cd_first_dt;

*to get exclusions number with ibd run above using num instead of base_cohort
	limiting to ibd/cd/uc counts >=n;

    /* we are now moving to IBD cohort specific exclusions */
    /* must have at least 1 CD diagnosis for this
       particular case definition
       can edit case definition here as needed
*/

    /****************************************/
    /* DO NOT DELETE UC AND IBD FROM DENOM  */
    /* denom will be wrong!!!!!             */
    /****************************************/


/*this case definition requires 1 dx for cd--no other criteria
nee to modify the where in the sort to create different case definitions*/

/*now that we have the final cohort we need to get some additional table 1 info from them relative to their qualifying
dx date*/

/*IBD surgery after CD diagnosis*/
/*read in the inpatient and outpatient IBD surgery data keeping only procedures after the cd date*/

	/*first make a dataset with only the minimum info about our cohort*/
proc sort data=&final_num_denom 
out=cohort_cd_min (keep = &pat_id  bene_msis_st_id cd_first_dt elig_end_dt); 
where cd_status=1;
by &pat_id;
run;
	/*now merge to the ip and op surgery files*/
%macro merge_data(in=, out=, date=);
proc sort data=&in; by &pat_id;
data &out (keep = &pat_id bene_msis_st_id ibd_surg_dt );
merge cohort_cd_min (in=a) 
&in (in=b)
;
by &pat_id;
if a and b;
if &date<cd_first_dt then delete; *delete before cd date;
if &date>elig_end_dt then delete; *delete after end of eligibility;
ibd_surg_dt=&date; format ibd_surg_dt date9.;
run;
proc sort data=&out NODUPKEY; by &pat_id ibd_surg_dt; run;
%mend;
%merge_data(in=&shlib..max_ibdsurg_ot_2010_2015, out=ibd_surg_max_op, date=ibd_op_surg_dt);
%merge_data(in=&shlib..max_ibdsurg_ip_2010_2015, out=ibd_surg_max_ip, date=ibd_ip_surg_dt);
%merge_data(in=&shlib..taf_ibdsurg_ot_2014_2019, out=ibd_surg_taf_op, date=ibd_op_surg_dt);
%merge_data(in=&shlib..taf_ibdsurg_ip_2014_2019, out=ibd_surg_taf_ip, date=ibd_surg_surg_dt);

/*merge inpatient and outpatient together and sum counts*/
data ibd_surg;
set ibd_surg_max_op ibd_surg_max_ip
	ibd_surg_taf_op ibd_surg_taf_ip;
run;
proc sort data=ibd_surg nodupkey; by bene_msis_st_id ibd_surg_dt;run;

%macro counts (in=, date=, date_first=, date_last=, out=, count=);
/*there should be no duplicates when this proc sort is run
    --if duplicates are deleted there is a problem above*/
proc sort data=&in nodupkey;
by bene_msis_st_id &date ;
run; /*there should be no duplicates here*/

data &out (keep = &pat_id &count &date_first &date_last);
set &in ;
by bene_msis_st_id &date;

if first.bene_msis_st_id then do; &count = 0; &date_first=&date; end; 
	&count + 1;
if last.bene_msis_st_id then do; &date_last=&date; end;
retain &date_first;
if last.bene_msis_st_id then output;
run;

proc freq data= &out ;
table &count;
run;
%mend;
%counts(in=ibd_surg,
		out=ibd_surg_cnt , 
		date= ibd_surg_dt, 
		date_first=ibd_surg_dt_first,
		date_last=ibd_surg_dt_last,
		count=ibd_surg_count );


/*IBD drugs START*/
/*read in the inpatient, outpatient and RX drugs after the cd date*/
/*do for each drug*/


%macro drug(drug_group=);
	/*now merge the drug files to the CD minimum cohort file made above */
	%macro merge_data(in=, out=, drug=, date=);
	proc sort data=&in; by &pat_id;
	data &out;
	merge 
	cohort_cd_min (in=a) 
	&in (in=b)
	;
	by &pat_id;
	if a and b;
		if &drug ne 1 then delete;
	if &date<cd_first_dt then delete; *delete before cd date;
	if &date>elig_end_dt then delete; *delete after end of eligibility;
	run;
	proc sort data=&out NODUPKEY; by &pat_id &date; run;
	%mend;
	%merge_data(in=&shlib..max_hcpcs_drug_ot_2010_2015, out=max_&drug_group._op, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..max_hcpcs_drug_ip_2010_2015, out=max_&drug_group._ip, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..max_ndc_drug_2010_2015, out=max_&drug_group._rx, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..taf_hcpcs_drug_ot_2014_2019, out=taf_&drug_group._op, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..taf_hcpcs_drug_ip_2014_2019, out=taf_&drug_group._ip, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..taf_ndc_drug_2014_2019, out=taf_&drug_group._rx, drug=&drug_group, date=&drug_group._dt);


	/*merge inpatient (hcpcs), outpatient (hcpcs), RX (ndc) together and sum counts*/
	data &drug_group;
	merge 	max_&drug_group._op max_&drug_group._ip max_&drug_group._rx
			taf_&drug_group._op taf_&drug_group._ip taf_&drug_group._rx;
	by &pat_id &drug_group._dt;
	run;
	%counts(in=&drug_group,
			out=&drug_group._cnt , 
			date= &drug_group._dt, 
			date_first=&drug_group._dt_first,
			date_last=&drug_group._dt_dt_last,
			count=&drug_group._count );
%mend;
%drug(drug_group=inflix);
%drug(drug_group=cert_peg);
%drug(drug_group=ada);
%drug(drug_group=golim);
%drug(drug_group=natal);
%drug(drug_group=ustek);
%drug(drug_group=vedo);
%drug(drug_group=steroids);
%drug(drug_group=asa);
%drug(drug_group=antibiotic);	
%drug(drug_group=biologic);	
%drug(drug_group=antiTNF);	
%drug(drug_group=immunomodulator);	
%drug(drug_group=mtx);	
%drug(drug_group=aza);	
%drug(drug_group=sixmp);	
%drug(drug_group=upa);	
%drug(drug_group=oza);
%drug(drug_group=cyclo);
%drug(drug_group=jak);
%drug(drug_group=tofa);

*IBD drugs stop;

*TPN (inpatient, outpatient, ndc) start;
%macro drug(drug_group=);
	/*now merge the drug files to the CD minimum cohort file made above */
	%macro merge_data(in=, out=, drug=, date=);
	proc sort data=&in; by &pat_id;
	data &out;
	merge 
	cohort_cd_min (in=a) 
	&in (in=b)
	;
	if &drug ne 1 then delete;
	by &pat_id;
	if a and b;
	if &date<cd_first_dt then delete; *delete before cd date;
	if &date>elig_end_dt then delete; *delete after end of eligibility;
	run;
	proc sort data=&out NODUPKEY; by &pat_id &date; run;
	%mend;
	%merge_data(in=&shlib..max_tpn_ot_2010_2015, out=MAX_&drug_group._op, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..max_tpn_ip_2010_2015, out=MAX_&drug_group._ip, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..max_ndc_tpn_2010_2015, out=MAX_&drug_group._rx, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..taf_tpn_ot_2014_2019, out=TAF_&drug_group._op, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..taf_tpn_ip_2014_2019, out=TAF_&drug_group._ip, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..taf_ndc_tpn_2014_2019, out=TAF_&drug_group._rx, drug=&drug_group, date=&drug_group._dt);


	/*merge inpatient (hcpcs), outpatient (hcpcs), RX (ndc) together and sum counts*/
	data &drug_group;
	merge MAX_&drug_group._op MAX_&drug_group._ip MAX_&drug_group._rx
		TAF_&drug_group._op TAF_&drug_group._ip TAF_&drug_group._rx;
	by &pat_id &drug_group._dt;
	run;
	%counts(in=&drug_group,
			out=&drug_group._cnt , 
			date= &drug_group._dt, 
			date_first=&drug_group._dt_first,
			date_last=&drug_group._dt_dt_last,
			count=&drug_group._count );
%mend;
%drug(drug_group=tpn);
*TPN drugs stop;

/*IBD hospitalizations after CD diagnosis*/
/*read in the inpatient IBD data keeping only hospitalizations after the cd date
		there is no outpatient data here*/

%macro merge_data(in=, out=, date=);
proc sort data=&in; by &pat_id;
data &out;
merge cohort_cd_min (in=a) 
&in (in=b)
;
by &pat_id;
if a and b;
if &date<cd_first_dt then delete; *delete before cd date;
if &date>elig_end_dt then delete; *delete after end of eligibility;
ibd_hosp_dt=&date; format ibd_hosp_dt date9.;
run;
proc sort data=&out NODUPKEY; by &pat_id ibd_hosp_dt; run;
%mend;
%merge_data(in=&shlib..max_ibdhosp_ip_2010_2015, out=max_ibd_hosp, date=ibd_ip_hosp_dt);
%merge_data(in=&shlib..taf_ibdhosp_ip_2014_2019, out=taf_ibd_hosp, date=ibd_ip_hosp_dt);

data ibd_hosp;
set max_ibd_hosp taf_ibd_hosp;
run;
%counts(in=ibd_hosp,
		out=ibd_hosp_cnt , 
		date= ibd_hosp_dt, 
		date_first=ibd_hosp_dt_first,
		date_last=ibd_hosp_dt_dt_last,
		count=ibd_hosp_count );
*note that we are counting all IBD hosps, can count CD, UC, IBD separately
		based on the input dataset--we assume that all hosps after CD
		are CD hosps even if recorded as UC (this may not be true if looking
		at UC);

/*fistula start;
*Use a variation of the IBD drugs macro for fistula since there are multiple types of fistula of interest*/
%macro drug(drug_group=);
%macro merge_data(in=, out=, drug=, date=);
	proc sort data=&in; by &pat_id;
	data &out 
			(drop = srvc_bgn_dt plc_of_srvc_cd 	fistula_plc_of_srvc_cd fistula_intest_plc_of_srvc_cd 
												fistula_peri_plc_of_srvc_cd fistula_rectvag_plc_of_srvc_cd);
	merge 
	cohort_cd_min (in=a) 
	&in (in=b)
	;
	if &drug ne 1 then delete;
	by &pat_id;
	if a and b;
	if &date<cd_first_dt then delete; *delete before cd date;
	if &date>elig_end_dt then delete; *delete after end of eligibility;
	run;
	proc sort data=&out NODUPKEY; by &pat_id &date; run;
	%mend;
	%merge_data(in=&shlib..max_fistula_op_2010_2015, out=max_&drug_group._op, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..max_fistula_ip_2010_2015, out=max_&drug_group._ip, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..TAF_fistula_ot_2014_2019, out=TAF_&drug_group._op, drug=&drug_group, date=&drug_group._dt);
	%merge_data(in=&shlib..TAF_fistula_ip_2014_2019, out=TAF_&drug_group._ip, drug=&drug_group, date=&drug_group._dt);

	/*merge inpatient (hcpcs), outpatient (hcpcs), RX (ndc) together and sum counts*/
	data &drug_group;
	merge max_&drug_group._op max_&drug_group._ip	
		taf_&drug_group._op taf_&drug_group._ip;
	by &pat_id &drug_group._dt;
	run;
	%counts(in=&drug_group,
			out=&drug_group._cnt , 
			date= &drug_group._dt, 
			date_first=&drug_group._dt_first,
			date_last=&drug_group._dt_dt_last,
			count=&drug_group._count );
%mend;
%drug(drug_group=fistula );
%drug(drug_group=fistula_intest  );
%drug(drug_group=fistula_perianal);   
%drug(drug_group=fistula_rectvag );   
*fistula stop;

/*tobacco/alcohol/opioids start;
*Use a variation of the IBD drugs macro for these since there*/
%macro drug(drug_group=);
%macro merge_data(in=, out=, drug=, date=, drop=);
	proc sort data=&in; by &pat_id;
	data &out 
			(drop = 	&drop);
	merge 
	cohort_cd_min (in=a) 
	&in (in=b)
	;
	if &drug ne 1 then delete;
	by &pat_id;
	if a and b;
	if &date<cd_first_dt then delete; *delete before cd date;
	if &date>elig_end_dt then delete; *delete after end of eligibility;
	run;
	proc sort data=&out NODUPKEY; by &pat_id &date; run;
	%mend;
	%merge_data(in=&shlib..max_substance_op_2010_2015, out=max_&drug_group._op, drug=&drug_group, date=&drug_group._dt,
						drop=cocaine_plc_of_srvc_cd opioids_plc_of_srvc_cd 
						 	etoh_plc_of_srvc_cd etoh_organ_plc_of_srvc_cd
							mdma_plc_of_srvc_cd cannabis_plc_of_srvc_cd
							tobacco_plc_of_srvc_cd plc_of_srvc_cd srvc_bgn_dt);
	%merge_data(in=&shlib..max_substance_ip_2010_2015, out=max_&drug_group._ip, drug=&drug_group, date=&drug_group._dt,
						drop = plc_of_srvc_cd srvc_bgn_dt /*srvc_end_dt yr_num*/);
	%merge_data(in=&shlib..taf_substance_op_2014_2019, out=TAF_&drug_group._op, drug=&drug_group, date=&drug_group._dt,
						drop = cocaine_plc_of_srvc_cd opioids_plc_of_srvc_cd 
						 	etoh_plc_of_srvc_cd etoh_organ_plc_of_srvc_cd
							mdma_plc_of_srvc_cd cannabis_plc_of_srvc_cd
							tobacco_plc_of_srvc_cd 
							plc_of_srvc_cd srvc_bgn_dt srvc_end_dt pos_cd yr_num);
	%merge_data(in=&shlib..taf_substance_ip_2014_2019, out=TAF_&drug_group._ip, drug=&drug_group, date=&drug_group._dt,
						drop = plc_of_srvc_cd srvc_bgn_dt srvc_end_dt yr_num);

	/*merge inpatient (hcpcs), outpatient (hcpcs), RX (ndc) together and sum counts*/
	data &drug_group;
	merge max_&drug_group._op max_&drug_group._ip	
		taf_&drug_group._op taf_&drug_group._ip;
	by &pat_id &drug_group._dt;
	run;
	%counts(in=&drug_group,
			out=&drug_group._cnt , 
			date= &drug_group._dt, 
			date_first=&drug_group._dt_first,
			date_last=&drug_group._dt_dt_last,
			count=&drug_group._count );
%mend;
%drug(drug_group=opioids );
%drug(drug_group=etoh  );
%drug(drug_group=tobacco);      
*tobacco/alcohol/opioids stop;


		/*after take all of the surg, hosps, meds, bring together then merge for table 1
			all will be 1 record per person*/
proc sort data = ibd_surg_cnt; 	by &pat_id; run;
proc sort data = ibd_hosp_cnt; 	by &pat_id; run;
proc sort data = inflix_cnt;	by &pat_id; run; 
proc sort data = cert_peg_cnt;	by &pat_id; run;
proc sort data = ada_cnt;		by &pat_id; run;
proc sort data = natal_cnt;		by &pat_id; run;
proc sort data = ustek_cnt;		by &pat_id; run;
proc sort data = vedo_cnt;		by &pat_id; run;
proc sort data = steroids_cnt;	by &pat_id; run;
proc sort data = asa_cnt;		by &pat_id; run;
proc sort data = antibiotic_cnt; by &pat_id; run;
proc sort data = biologic_cnt;	by &pat_id; run;
proc sort data = antiTNF_cnt;	by &pat_id; run;
proc sort data = immunomodulator_cnt;	by &pat_id; run;
proc sort data = mtx_cnt;		by &pat_id; run;
proc sort data = aza_cnt;		by &pat_id; run;
proc sort data = sixmp_cnt;		by &pat_id; run;
proc sort data = golim_cnt;		by &pat_id; run;
proc sort data = upa_cnt;		by &pat_id; run;
proc sort data = oza_cnt;		by &pat_id; run;
proc sort data = cyclo_cnt;		by &pat_id; run;
proc sort data = tofa_cnt;		by &pat_id; run;
proc sort data = jak_cnt;		by &pat_id; run;
proc sort data = tpn_cnt 	;	by &pat_id; run;
proc sort data = fistula_cnt ;		by &pat_id; run;
proc sort data = fistula_intest_cnt  ;	by &pat_id; run;
proc sort data = fistula_perianal_cnt;	by &pat_id; run;   
proc sort data = fistula_rectvag_cnt ;	by &pat_id; run; 
proc sort data = opioids_cnt 	;	by &pat_id; run;
proc sort data = etoh_cnt 	;	by &pat_id; run;
proc sort data = tobacco_cnt 	;	by &pat_id; run;
  
data stuffFORtable1;
merge ibd_surg_cnt ibd_hosp_cnt 
inflix_cnt cert_peg_cnt ada_cnt natal_cnt ustek_cnt vedo_cnt steroids_cnt asa_cnt
golim_cnt upa_cnt oza_cnt cyclo_cnt tofa_cnt jak_cnt tpn_cnt
antibiotic_cnt biologic_cnt antiTNF_cnt immunomodulator_cnt mtx_cnt aza_cnt sixmp_cnt
fistula_cnt fistula_intest_cnt fistula_perianal_cnt fistula_rectvag_cnt
opioids_cnt etoh_cnt tobacco_cnt; 
by &pat_id; 
run;
*check to make sure no extraneous vars here: pos_cd, yr_num, etc;

data &tmp_out_fnl_all._try;							*note the TRY & obs=!!!!;
merge stuffFORtable1 &final_num_denom  (/*obs=200000*/ in=a) ;
by &pat_id;
if a;
*make variable for no use of any IBD drug;
if 	inflix_count=0 AND cert_peg_count=0 and ada_count=0 and natal_count=0
	AND ustek_count=0 AND vedo_count=0 and immunomodulator_count=0
	AND golim_count=0 AND upa_count=0 AND oza_count=0 AND tofa_count=0
	THEN bio_or_imm=0; else bio_or_imm=1; 
	label bio_or_imm='patient used a biologic or immunomdoluator at least once';
*make binary indicators;
if ibd_surg_count>=1 then ibd_surg_bin=1;
if ibd_hosp_count>=1 then ibd_hosp_bin=1;
if inflix_count>=1 then inflix_bin=1;
if cert_peg_count>=1 then cert_peg_bin=1;
if ada_count>=1 then ada_bin=1;
if natal_count>=1 then natal_bin=1;
if ustek_count>=1 then ustek_bin=1;
if vedo_count>=1 then vedo_bin=1;
if steroids_count>=1 then steroids_bin=1;
if asa_count>=1 then asa_bin=1;
if antibiotic_count>=1 then antibiotic_bin=1;
if biologic_count>=1 then biologic_bin=1;
if antiTNF_count>=1 then antiTNF_bin=1;
if immunomodulator_count>=1 then immunomodulator_bin=1;
if mtx_count>=1 then mtx_bin=1;
if aza_count>=1 then aza_bin=1;
if sixmp_count>=1 then sixmp_bin=1;
if tpn_count >=1 				then tpn_bin=1;
if golim_count>=1 				then golim_bin=1;
if upa_count>=1					then upa_bin=1;
if oza_count>=1 				then oza_bin=1;
if cyclo_count>=1				then cyclo_bin=1;
if tofa_count>=1				then tofa_bin=1;
if jak_count>=1					then jak_bin=1; 
if fistula_count >=1 			then fistula_bin=1;
if fistula_intest_count >=1 	then fistula_intest_bin=1;
if fistula_perianal_count >=1 	then fistula_perianal_bin=1;
if fistula_rectvag_count >=1 	then fistula_rectvag_bin=1;
if opioids_count >=1 			then opioids_bin=1;
if etoh_count >=1 				then etoh_bin=1;
if tobacco_count >=1 			then tobacco_bin=1;
/*make compacted eligibility variable;
if cd_first_elgblty_cd_max in('00' '14' '15' '41' '44' '45' '48' '51' '54' '55' '99') 	then cd_first_elgblty_cat='OTHER       ';
if cd_first_elgblty_cd_max in('11' '16' '17' '31' '34' '35' '3A') 						then cd_first_elgblty_cat='INCOME-BASED';
if cd_first_elgblty_cd_max in('12' '21' '22' '24' '25' '32' '42' '52') 					then cd_first_elgblty_cat='DISABLED/MEDICAL';
if el_max_elgblty_cd_ltst in('00' '14' '15' '41' '44' '45' '48' '51' '54' '55' '99') 	then el_max_elgblty_cat='OTHER       ';
if el_max_elgblty_cd_ltst in('11' '16' '17' '31' '34' '35' '3A') 						then el_max_elgblty_cat='INCOME-BASED';
if el_max_elgblty_cd_ltst in('12' '21' '22' '24' '25' '32' '42' '52') 					then el_max_elgblty_cat='DISABLED/MEDICAL';
*format cd_last_elgblty_cd_max $elig.;*/
*different cd counts;
if cd_count>=1 then cd_count1plus_bin=1;
if cd_count>=2 then cd_count2plus_bin=1;
run;

/*** created macro to change all missing numeric values to zero ***/
%macro numtozero(inds=,
                 outds=,
                 dropvars= i ) ;

 data &outds;
  set &inds;
       array testmiss(*)  _numeric_;
       do i =1 to dim(testmiss);
          if testmiss{i} =  . then testmiss{i}=0;
        end;
       drop &dropvars;
 run;
%mend;
%numtozero(inds    = &tmp_out_fnl_all._try,
           outds   = &tmp_out_fnl_all._try,
           dropvars= i ) ;


/*use this code ONLY if ran demographics above for full cohort with elig_start_dt instead of cd_first_dt
		   and without restriction to cd;
data &final_num_denom; set &tmp_out_fnl_all._try; run;
*/


*make permanent dataset of 1+dx for ease of testing rate codes;
data &shlib..&proj_ds_pfx.cd_rate_num_denom_1dxDELETE; set &tmp_out_fnl_all._try; *note the TRY & obs=!!!!;
where cd_count>=1;
run;
*187,417,009 all patients in &tmp_out_fnl_all._try;
*437,540 where at least 1 cd dx encounter;

data cd_cohort ; set &shlib..&proj_ds_pfx.cd_rate_num_denom_1dxDELETE; 
*if den_race_eth_cd notin('1','2') then den_race_eth_cd=9;
if cd_first_plc_of_srvc_cd notin('11','21','22','23') then cd_first_plc_of_srvc_cd='99';
cd_first_yr=year(cd_first_dt);
where cd_count>=1;* and uc_count=0;
*where cd_count>=2 and fup_b4_cd>1;
*where cd_count>=2 and fup_b4_cd>1 and (immunomodulator_bin=1 or biologic_bin=1 or steroids_bin=1);
*where ibd_count=0;
*where ibd_count=0 and elig_days_10_19>=365; 
run;
proc freq data=cd_cohort;
table den_race_eth_cd elig_grp cd_first_plc_of_srvc_cd cd_first_yr;
run;

*start of tables for manu;
*percents for the frequency variables;
%macro demogs(status=, var=);
proc freq data=cd_cohort /*order=freq*/ noprint; 
where cd_status=&status;
table  	&var /nocum out=&var; run;
data &var (drop = table f_&var frequency cumfrequency cumpercent &var); 
retain var label; 
format label $40.;
set &var;
var="&var";
label=&var;
if frequency<11 then frequency=.;
if cumfrequency<11 then cumfrequency=.;
run;
%mend;
Title 'Demographics of Crohn Patients';
%demogs(status=1, var=cd_status );
%demogs(status=1, var=cd_count1plus_bin );
%demogs(status=1, var=cd_count2plus_bin );
%demogs(status=1, var=cd_first_yr );
%demogs(status=1, var=start_yr );
%demogs(status=1, var=female);
%demogs(status=1, var=den_race_eth_cd);
%demogs(status=1, var=den_age_cat);
        %demogs(status=1, var=  cd_first_plc_of_srvc_cd	);
        *%demogs(status=1, var=  cd_first_elgblty_cd_max	);
		*%demogs(status=1, var=  cd_first_elgblty_cat	);
		*%demogs(status=1, var=  cd_last_elgblty_cd_max 	);
		*%demogs(status=1, var=  el_max_elgblty_cd_ltst 	);
		*%demogs(status=1, var=  el_max_elgblty_cat		);
		%demogs(status=1, var=  elig_grp				);
		%demogs(status=1, var=  ibd_surg_bin		  	);
		%demogs(status=1, var=  ibd_hosp_bin		  	);
		%demogs(status=1, var=  fistula_bin 			);
		%demogs(status=1, var=  fistula_intest_bin 		);
		%demogs(status=1, var=  fistula_perianal_bin	); 
		%demogs(status=1, var=  fistula_rectvag_bin		);
		%demogs(status=1, var=  tpn_bin					);
		%demogs(status=1, var=  inflix_bin				);
		%demogs(status=1, var=  cert_peg_bin		  	);
		%demogs(status=1, var=  ada_bin			  		);
		%demogs(status=1, var=  natal_bin				);
		%demogs(status=1, var=  ustek_bin				);
		%demogs(status=1, var=  vedo_bin			  	);
		%demogs(status=1, var=  steroids_bin		  	);
		%demogs(status=1, var=  asa_bin			  		);
		%demogs(status=1, var=  antibiotic_bin	 		);
		%demogs(status=1, var=  biologic_bin		  	);
		%demogs(status=1, var=  antiTNF_bin		  		);
		%demogs(status=1, var=  immunomodulator_bin  	);
		%demogs(status=1, var=  mtx_bin			  		);
		%demogs(status=1, var=  aza_bin			  		);
		%demogs(status=1, var=  sixmp_bin				);
		%demogs(status=1, var=  golim_bin				);
		%demogs(status=1, var=  upa_bin				);
		%demogs(status=1, var=  oza_bin				);
		%demogs(status=1, var=  cyclo_bin				);
		%demogs(status=1, var=  tofa_bin				);
		%demogs(status=1, var=  jak_bin				);
		%demogs(status=1, var=  cd_first_yr				);
		%demogs(status=1, var=  tobacco_bin			);
		%demogs(status=1, var=  etoh_bin				);
		%demogs(status=1, var=  opioids_bin				);




data table10_19 (drop = count percent); 
length var $20.;
retain definition;
set
cd_status cd_count1plus_bin cd_count2plus_bin
den_race_eth_cd den_age_cat
female 	
ibd_surg_bin ibd_hosp_bin  tpn_bin		  	
fistula_bin  fistula_intest_bin  fistula_perianal_bin	  fistula_rectvag_bin	
inflix_bin cert_peg_bin ada_bin natal_bin ustek_bin vedo_bin
golim_bin upa_bin oza_bin  cyclo_bin tofa_bin jak_bin biologic_bin antiTNF_bin		
steroids_bin asa_bin antibiotic_bin	 		
immunomodulator_bin mtx_bin aza_bin sixmp_bin	
opioids_bin tobacco_bin etoh_bin 	
cd_first_yr cd_first_plc_of_srvc_cd elig_grp/*cd_first_elgblty_cd_max cd_first_elgblty_cat	
/*cd_last_elgblty_cd_max el_max_elgblty_cd_ltst  el_max_elgblty_cat*/	
;
if 1<=count<=10 then do; count=.; percent=.;end;
year2010_2019_count=count;
year2010_2019_percent=percent;
if var notin('den_age_cat', 'den_race_eth_cd', 'cd_first_plc_of_srvc') then do;
	if label=0 then delete;
end;
definition = '>=1 cd dx and 0 uc dx';
run;

*now do same for means then stack;
%macro demogs(status=, var=);
proc means data=cd_cohort  n mean median min max ;
where cd_status=&status;
var  &var ;
output out=&var (drop=_type_ _freq_ ) 
n= mean= median= min= max= std= q1= q3= / autoname;
run;
data &var (drop = &var._n &var._mean &var._median &var._max &var._min
						&var._stddev &var._q1 &var._q3);
retain var ; 
format var $40.;
set &var;
var="&var";
if &var._n<11 then &var._n=.;
*if &var._mean<11 then &var._mean=.;
*if &var._median<11 then &var._median=.;
*if &var._max<11 then &var._max=.;
*if &var._stddev<11 then &var._stddev=.;
if &var._q1<11 then &var._q1=.;
if &var._q3<11 then &var._q3=.;
rename &var._n = n;
rename &var._mean = mean;
rename &var._median = median;
rename &var._min = min;
rename &var._max = max;
rename &var._stddev = stddev;
rename &var._q1 = q1;
rename &var._q3 = q3;
run;
%mend;
%demogs(status=1, var=elig_days_10_19  );
%demogs(status=1, var=fup_medicaid  );
        %demogs(status=1, var=  den_age   );
        %demogs(status=1, var=  cd_first_age    );
        *%demogs(status=1, var=  cd_fup          );
        %demogs(status=1, var=  fup_after_CD    );
        %demogs(status=1, var=  fup_b4_cd       );
        %demogs(status=1, var=  cd_count        );
        %demogs(status=1, var=  uc_count        );
        %demogs(status=1, var=  ibd_count       );
        %demogs(status=1, var=  cd_prop         );
		%demogs(status=1, var=  ibd_surg_count		  	);
		%demogs(status=1, var=  ibd_hosp_count		  	);
		%demogs(status=1, var= fistula_count 			);
		%demogs(status=1, var= fistula_intest_count 	);
		%demogs(status=1, var= fistula_perianal_count	); 
		%demogs(status=1, var= fistula_rectvag_count	);
		%demogs(status=1, var= tpn_count				);
		%demogs(status=1, var=  inflix_count			);
		%demogs(status=1, var=  cert_peg_count		  	);
		%demogs(status=1, var=  ada_count			  	);
		%demogs(status=1, var=  natal_count			);
		%demogs(status=1, var=  ustek_count			);
		%demogs(status=1, var=  vedo_count			  	);
		%demogs(status=1, var=  steroids_count		  	);
		%demogs(status=1, var=  asa_count			  	);
		%demogs(status=1, var=  antibiotic_count		);
		%demogs(status=1, var=  biologic_count		  	);
		%demogs(status=1, var=  antiTNF_count		  	);
		%demogs(status=1, var=  immunomodulator_count  );
		%demogs(status=1, var=  mtx_count			  	);
		%demogs(status=1, var=  aza_count			  	);
		%demogs(status=1, var=  sixmp_count			);
		%demogs(status=1, var=  opioids_count			);
		%demogs(status=1, var=  etoh_count			);
		%demogs(status=1, var=  tobacco_count			);
data table_means_10_19 ; 
length var $20.;
retain definition;
set
elig_days_10_19  fup_medicaid   den_age   
cd_first_age  /*cd_fup*/  fup_after_CD  fup_b4_cd       
cd_count  uc_count  ibd_count   cd_prop         
ibd_surg_count	ibd_hosp_count		  	
 fistula_count fistula_intest_count fistula_perianal_count fistula_rectvag_count	
tpn_count inflix_count cert_peg_count  ada_count			  	
natal_count	ustek_count vedo_count			  	
steroids_count	 asa_count	antibiotic_count		
biologic_count antiTNF_count		  	
immunomodulator_count  mtx_count aza_count sixmp_count	
opioids_count etoh_count tobacco_count	
;
definition = '>=1 cd dx and 0 uc dx';
run;

proc contents data=cd_cohort; run;
proc freq data=cd_cohort; table cd_first_yr start_yr cd_inc_year: cd_prev_year: den_year:; run;


*note that we are using the cd and non-cd pop here--&final_num_denom

above tables used cd only for efficiency;

*rate
num: cd_cohort
denom: &tmp_out_fnl_all._try
;

/*** Calculate Incidence and Prevalence Rate BY YEAR
		This uses the July 1 midpoint for denominator (ex: den_year2011)
	You can only use this macro to calculate by YEAR---NOT all years combined***/
%macro rate(tmp_in       = ,
            tmp_out      = ,
            class_vars      = ,
            main_var_cnt = ,
            main_var_name=,
			denom=,
			num=,
			where1=
            );
/* denominator for rate */
data in 
						(keep = &pat_id female den_race_eth_cd 
							den_age_cat den_state_cd 
							den_year&tmp_merge_year den_year_&tmp_merge_year
							cd_inc_year_&tmp_merge_year cd_prev_year_&tmp_merge_year
							cd_count uc_count elig_days_10_19 fup_b4_cd
							immunomodulator_bin biologic_bin steroids_bin );
    set &final_num_denom (keep = &pat_id female den_race_eth_cd 
							den_age_&tmp_merge_year den_state_cd_&tmp_merge_year
							den_year&tmp_merge_year den_year_&tmp_merge_year
							cd_inc_year_&tmp_merge_year cd_prev_year_&tmp_merge_year
							cd_count uc_count elig_days_10_19 fup_b4_cd
							immunomodulator_bin biologic_bin steroids_bin );*&tmp_out_fnl_all._try ;
    where &where1;
/*create a flag for eligibility so can calculate rates across all years together*/
den_elig_pop=1;
/*rename vars for year*/
den_state_cd=den_state_cd_&tmp_merge_year;
den_age=den_age_&tmp_merge_year;
    /** turn continuous age into category **/
    if 0  <= den_age <= 5   then den_age_cat = 05   ;
    if 5  <  den_age <= 10  then den_age_cat = 0510  ;
    if 10 <  den_age <= 20  then den_age_cat = 1020 ;
    if 20 <  den_age <= 30  then den_age_cat = 2030 ;
    if 30 <  den_age <= 40  then den_age_cat = 3040 ;
    if 40 <  den_age <= 50  then den_age_cat = 4050 ;
    if 50 <  den_age <= 60  then den_age_cat = 5060 ;
    if 60 <  den_age <= 70  then den_age_cat = 6070 ;
    if 70 <  den_age <= 80  then den_age_cat = 7080 ;
    if 80 <  den_age <= 105 then den_age_cat = 80105;
run;

    proc summary data= in
                       (keep   =_all_
                        rename =(
                              &main_var_cnt= key_n_var
                                 )
                        )   nmiss  ;* nway;
        *class key_n_var ;
        class &class_vars    ;
        var key_n_var ;
        output out=&tmp_out;*
             (drop  =_freq_	)
        ;
    run;
	data &tmp_out (drop = key_n_var _stat_); retain year; set &tmp_out;
	year=&tmp_merge_year;
	*rename key_n_var = year;
	rename _freq_ = &main_var_name ;
	where _stat_="N";
	run;
%mend;
%let tmp_class_facts = female den_age_cat den_race_eth_cd;* den_state_cd; 
/** den age cat does age at first eligiblity NOT this year--wrong variable! same with state **/
%let tmp_merge_year  = 2011 ; /*need to change this manually for each year*/
%let denom_year=den_year&tmp_merge_year;
	*denom options--with or iwthout underscore:
		den_yearNNNN = midyear					--- use for prevalence sicne prev calculated on july 1
		den_year_NNNN = anytime during the year--no fup requirement--can add in where clause --- use for incidence;
						*for prev anytime during year use where cd_first_dt cd_last_dt;
%let num_inc=cd_inc_year_&tmp_merge_year;
%let num_prev=cd_prev_year_&tmp_merge_year;
*incident no eligiblity requirement;
*start;
*identify denom and num with where clauses;
*denominator;
*%let where_denom=&denom_year=1; *use for standard point prevalence;*def 1,2;
%let where_denom=&denom_year=1 and elig_days_10_19>=365; *use for prevalence with at 1 least 1 yr cd fup;* def 3;

%rate (
       tmp_out       = fnl_denom_sum&tmp_merge_year            ,
       class_vars       = &tmp_class_facts      ,
       main_var_cnt  = den_year&tmp_merge_year     ,
       main_var_name = dn_n_cnt,
	   where1=&where_denom
       );
*incidence--if want incident by july 1 to match denom then have to add in denom requirement too!!!;
	   *our incidence indicator is based on first time observed in data--require 1 yr before requirement
	   		to calculate incidence;
	   *if use denom_year_ (with underscore) then we are using incidence ANYTIME in year, don't use denom requirement;
*%let  where_num_inc = &denom_year=1 and &num_inc=1 and cd_count>=1 and fup_b4_cd>1 and elig_days_10_19>=365; *def 1;
*%let  where_num_inc = &denom_year=1 and &num_inc=1 and cd_count>=2 and fup_b4_cd>1 and elig_days_10_19>=365; *def 2;
*%let  where_num_inc = &denom_year=1 and &num_inc=1 and cd_count>=2 and fup_b4_cd>1 and elig_days_10_19>=365
	   and (immunomodulator_bin=1 or biologic_bin=1 or steroids_bin=1); *def 3;

	   

*%rate (
       tmp_out       = fnl_denom_sum_incid&tmp_merge_year     ,
       class_vars       = &tmp_class_facts            ,
       main_var_cnt  = cd_inc_year_&tmp_merge_year  ,
       main_var_name = cd_incid_cnt,
	   where1=&where_num_inc
       );
*prevalence;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=1; *def 1;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=1 and elig_days_10_19>=365;*def 3;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=2; *def 2;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=2 and elig_days_10_19>=365 ;*def 4;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=1 and uc_count=0;*def 7;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=2 and uc_count=0;*def 8;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=2 and elig_days_10_19>=365 
						and fup_b4_cd>1;*will be blank for 2010; *def5;
%let where_num_prev = &denom_year=1 and &num_prev=1 and cd_count>=2 and elig_days_10_19>=365 
						and fup_b4_cd>1
						and (immunomodulator_bin=1 or biologic_bin=1 or steroids_bin=1);*def6; *will be blank for 2010;

%rate (
       tmp_out       = fnl_denom_sum_prev&tmp_merge_year      ,
       class_vars       = &tmp_class_facts            ,
       main_var_cnt  = cd_prev_year_&tmp_merge_year  ,
       main_var_name = cd_prev_cnt,
	   where1=&where_num_prev
       );

/*	   
proc sort data=fnl_denom_sum&tmp_merge_year; 		by _type_ year &tmp_class_facts;
proc sort data=fnl_denom_sum_incid&tmp_merge_year; 	by _type_ year &tmp_class_facts;
run;
data incidence_rate&tmp_merge_year;
    merge fnl_denom_sum&tmp_merge_year
          fnl_denom_sum_incid&tmp_merge_year;
    by _type_
       year
       &tmp_class_facts;
    inc_rate        =  cd_incid_cnt / dn_n_cnt;
    inc_rateper1000 =  inc_rate*1000;
    inc_rateper100K =  inc_rate*100000;
    if 0<cd_incid_cnt <11 then do; cd_incid_cnt =.;inc_rate=.;inc_rateper1000 =.;inc_rateper100K=.;end;
    if 0<dn_n_cnt     <11 then do; dn_n_cnt     =.;inc_rate=.;inc_rateper1000 =.;inc_rateper100K=.;end;
	*definition="incident any time during year, denom is based on enrolled on july 1 with at least 15 days";
run;*/

proc sort data=fnl_denom_sum&tmp_merge_year; by _type_ year &tmp_class_facts;
proc sort data=fnl_denom_sum_prev&tmp_merge_year; by _type_ year &tmp_class_facts;
run;

data prevalence_rate&tmp_merge_year;
retain definition;
    merge fnl_denom_sum&tmp_merge_year
          fnl_denom_sum_prev&tmp_merge_year;
    by _type_
       year
       &tmp_class_facts;
    prev_rate        =  cd_prev_cnt / dn_n_cnt;
    prev_rateper1000 =  prev_rate*1000;
    prev_rateper100K =  prev_rate*100000;
    if 0<cd_prev_cnt   <11 then do; cd_prev_cnt =.; prev_rate=.;prev_rateper1000 =.;prev_rateper100K=.;end;
    if 0<dn_n_cnt      <11 then do; dn_n_cnt    =.; prev_rate=.;prev_rateper1000 =.;prev_rateper100K=.;end;
	definition="point prevalence july 1, denom enrolled july 1";
run;
data prevalence_def1; retain definition;
set prevalence_rate2010 - prevalence_rate2019;
definition="prev def1: >=1 cd dx code, point prevalence july 1";*, denom enrolled july 1";
*definition="prev def2: >=2 cd dx code, point prevalence july 1";*, denom enrolled july 1";
run;


/*proc print data=incidence_rate&tmp_merge_year;
where _type_=0;
title "incidence rate for &tmp_merge_year";
run;
data incidence_def1; retain definition;
set incidence_rate2010 - incidence_rate2019;
definition="inc def1: >=1 cd dx code, point prevalence july 1";*, denom enrolled july 1";
*definition="inc def2: >=2 cd dx code, point prevalence july 1";*, denom enrolled july 1";
run;
*/


proc print data=prevalence_rate&tmp_merge_year;
where _type_=0;
title "prevalence rate for &tmp_merge_year";
run;

/*bring all definitions into a single dataset*/

data &shlib..mdcd_cd_prev_rt_10_19;
set prevalence_def1 - prevalence_def8;
run;

data &shlib..mdcd_cd_inc_rt_10_19;
set incidence_def1 - incidence_def3;
run;

/*if want inc and prev in same table*/
data shu172sl.mdcd_cd_rates_by_year_10_19 (drop = _stat_);
merge 	prevalence_rate2010 - prevalence_rate2019 
	  	incidence_rate2010  - incidence_rate2019
;
by _type_ year female den_age_cat den_race_eth_cd den_state_cd;
if 1<=dn_n_cnt<=10 then do; dn_n_cnt=.;cd_prev_cnt=.;cd_incid_cnt=.;end;
if 1<=cd_prev_cnt<=10 then cd_prev_cnt=.;
if 1<=cd_incid_cnt<=10 then cd_incid_cnt=.;
if _stat_ ne 'N' then delete;
run;
/*to get rates for each year*/
proc print data=rates_by_year;
where _type_=0;
run;

*model predictors of cd;
data modelcd; set USE AN NWAY VERSION OF THE RATE MACRO ABOVE!!!!;
run;
proc genmod data = modelcd;
  class female den_age_cat den_race_eth_cd  year /param=glm;
  model cd = female den_age_cat den_race_eth_cd year/ type3 offset=log_fup dist=poisson;
  *store p1;
run;



/*modify to get get different summaries of rates by year*
*rate per year;
proc print data=rates_by_year;
where year ne . and female=. and age_cat=. and statecode=' ' and den_race_eth_cd=' ';
run;

*rate per sex;
proc print data=rates_by_year;
where year = . and female ne . and age_cat=. and statecode=' ' and den_race_eth_cd=' ';
run;

*rate per age;
proc print data=rates_by_year;
where year = . and female = . and age_cat ne . and statecode=' ' and den_race_eth_cd=' ';
run;

*rate per state;
proc print data=rates_by_year;
where year = . and female = . and age_cat = . and statecode ne ' ' and den_race_eth_cd=' ';
run;

*rate per race/eth;
proc print data=rates_by_year;
where year = . and female = . and age_cat = . and statecode = ' ' and den_race_eth_cd ne ' ';
run;

        proc gmap data= rates_by_year (rename=den_state_cd=statecode) map=mapsgfk.us;
        where _type_=1;
                id statecode;
                choro rateper100K / levels=5;
                label rateper100K='Rate per 100,000 Medicaid Beneficiaries';
        run;
        quit;
*/

/*now generate rates across entire dataset not taking into account incidence/prevalence by year*/
/*** summarize based on all who contributed at least 1 day to denom or num***/
%macro rate2(in=,count=, out=);
proc summary data= &in nmiss;* nway; *use nway to make model for genmod/poisson regression;
/*class den_year2010;
class den_year2011;
class den_year2012;
class den_year2013;
class den_year2014;*/
class female   ;
class den_age_cat;
class den_race_eth_cd     ;
class den_state_cd    ;
*class &den_zip      ;
*class county   ;
var  den_elig_pop;
output out=&out
                        (drop  =_freq_ )
n                 =&count
;
run;
%mend;
%rate2(in=fnl_denom ,count=dn_n_cnt,  out=den);
%rate2(in=fnl_num , count=cd_n_cnt, out=num);
data grouprates;
    merge den
          num;
    by _type_
       female
		den_age_cat
		den_race_eth_cd
		den_state_cd;
rate= cd_n_cnt / dn_n_cnt;
rateper1000=rate*1000;
rateper100K=rate*100000;
if cd_n_cnt<11 then cd_n_cnt=.;
if dn_n_cnt<11 then dn_n_cnt=.;
run;

proc print data=grouprates; where _type_=0; run; *entire population;

*rate per year;
proc print data=grouprates; 
where den_year2010 ne . and female=. and den_age_cat=. and den_state_cd=' ' and den_race_eth_cd=' ';
run; 
*rate per sex;
proc print data=grouprates; 
where female ne . and den_age_cat=. and den_state_cd=' ' and den_race_eth_cd=' ';
run;
*rate per age;
proc print data=grouprates; 
where female = . and den_age_cat ne . and den_state_cd=' ' and den_race_eth_cd=' ';
run;
*rate per state;
proc print data=grouprates; 
where female = . and den_age_cat = . and den_state_cd ne ' ' and den_race_eth_cd=' ';
run;
*rate per race/eth;
proc print data=grouprates; 
where female = . and den_age_cat = . and den_state_cd = ' ' and den_race_eth_cd ne ' ';
run;

        proc gmap data= grouprates (rename=den_state_cd=statecode) map=mapsgfk.us;
		where _type_=1;
                id statecode;
                choro rateper100K / levels=5; label rateper100K='Rate per 100,000 Medicaid Beneficiaries';
        run;




