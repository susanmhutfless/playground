/********************************************************************
* Job Name: 2_mdcd_taf_OP_IBDSurg.sas
* Job Desc: Identify all IBD-related surgical procedures (outpatient setting only)
* COPYRIGHT (c) 2019 2020 2021 Johns Hopkins University - HutflessLab
********************************************************************/

/** alert - the job and settings in 0_setup_facts.sas must be set first **/

/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;   /** libname prefix **/
%global pat_idb clm_id                       ;
%global pat_id                               ;

/*** libname prefix alias assignments ***/
%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_surg_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										  hosp stands for ibd surgery  ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = taf_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.ibdsurg_ot_2014_2019;

%let  pat_idb            = bene_id  state_cd msis_id         ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;


%global proc_pfx clm_beg_dt	clm_end_dt        ;
%let  proc_pfx           = line_prcdr_cd       ;
*%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;
%let  clm_beg_dt         = line_srvc_bgn_dt  	 ;
%let  clm_end_dt         = line_srvc_end_dt   ;



%global ibd_sur_09_criteria_2 ibd_sur_09_criteria_3 ibd_sur_09_criteria_4 
		ibd_sur_10_criteria_2 ibd_sur_cpt_criteria     ;

/*need to use substrings for 9 and 10 here!*/
%let  ibd_sur_09_criteria_2   = '46'													;
%let  ibd_sur_09_criteria_3   = '173' '456' '457' '458' '459' '484' '485' '486' '491'	;
%let  ibd_sur_09_criteria_4   = '4973' '5783' '7072' '7073' '7074'						;

%let  ibd_sur_10_criteria_2   = '0D';

%let  ibd_sur_cpt_criteria =    '44120' '44121' '44122' '44123' '44124' '44125' 
								'44126' '44127' '44128' '44129'
								'44130' '44131' '44132' '44133' '44134' '44135' 
								'44136' '44137' '44138' '44139'
								'44140' '44141' '44142' '44143' '44144' '44145' 
								'44146' '44147' '44148' '44149'
								'44150' '44151' '44152' '44153' '44154' '44155' 
								'44156' '44157' '44158' '44159' '44160'
								'44202' '44203' '44204' '44205' '44206' '44207'
								'44208' '44209' '44210' '44211' '44212' '44213'
								'44227' '44625' '44626' 
								'45100' '45101' '45102' '45103' '45104' '45105'
								'45106' '45107' '45108' '45109'
								'45110' '45111' '45112' '45113' '45114' '45115'
								'45116' '45117' '45118' '45119'
								'45120' '45121' '45122' '45123' '45124' '45125'
								'45126' '45127' '45128' '45129'
								'45130' '45131' '45132' '45133' '45134' '45135'
								'45136' '45137' '45138' '45139'
								'45140' '45141' '45142' '45143' '45144' '45145'
								'45146' '45147' '45148' '45149'
								'45150' '45151' '45152' '45153' '45154' '45155'
								'45156' '45157' '45158' '45159'
								'45160' '45161' '45162' '45163' '45164' '45165'
								'45166' '45167' '45168' '45169'
								'45170' '45171' '45172' 
								'45395' '45397'
								'46020' '46030' '46040' '46045' '46050' '46060'
								'46258' '46270' '46275' '46280' '46285' '46288' 
								'46706' '46707' '46715'
								'57300' '57305' '57307' '57308'
								;
/***************************************************
ICD-10 PROCEDURE - need this additional info to look at specific procedures!
if (substr(icd9_pr,1,2)) in ('0D') and
   (substr(icd9_pr,3,1)) in ('B' 'P' 'Q' 'T') and
   (substr(icd9_pr,4,1)) in ('8' '9' 'A' 'B'
                             'C' 'D' 'E' 'F'
                             'G' 'H' 'K' 'L'
                             'M' 'N' 'P')
***************************************************/

/**flag for ibd surgery  **/
%global flag_ibd_surg  ;
%let    flag_ibd_surg          = ibd_op_surg  ;
/**  **/



/*** end of section   - global vars ***/


%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = taf;


/*** this section is related to ot - inpatient claims ***/
/*   get inpatient IBD hospitalizations                   */


%macro ibdyear(serveryear=, ibdyear=);
		data    &ibdyear;
		          set &serveryear 
(keep= &pat_id &proc_pfx  &clm_beg_dt &clm_end_dt) ;
           where substr(&proc_pfx,1,2) in ( &ibd_sur_09_criteria_2 &ibd_sur_10_criteria_2 ) or
				substr(&proc_pfx,1,3) in ( &ibd_sur_09_criteria_3 ) or
				substr(&proc_pfx,1,4) in ( &ibd_sur_09_criteria_4 ) or
				&proc_pfx in ( &ibd_sur_cpt_criteria ) ;
			*more nuance to icd10 surgeries;
					if substr(&proc_pfx,1,2) in(&ibd_sur_09_criteria_2) then do; surg=1; end;
					if substr(&proc_pfx,1,3) in(&ibd_sur_09_criteria_3) then do; surg=1; end;
					if substr(&proc_pfx,1,4) in(&ibd_sur_09_criteria_4) then do; surg=1; end;
					if &proc_pfx in(&ibd_sur_cpt_criteria) then do; surg=1; end;
					if substr(&proc_pfx,1,2) in(&ibd_sur_10_criteria_2) 
					then do;
						if 	(substr(&proc_pfx,3,1)) in ('B' 'P' 'Q' 'T') and
   							(substr(&proc_pfx,4,1)) in ('8' '9' 'A' 'B'
					                             'C' 'D' 'E' 'F'
					                             'G' 'H' 'K' 'L'
					                             'M' 'N' 'P') then surg=1;
					end;
				if surg ne 1 then delete;
				drop surg;
     run;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_surg_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_surg_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_surg_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_surg_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_surg_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_surg_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_surg_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_surg_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_surg_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_surg_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_surg_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_surg_20&NN._12);
data ibd_surg_20&NN.;
set ibd_surg_20&NN._01 - ibd_surg_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_surg_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_surg_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_surg_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_surg_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_surg_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_surg_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_surg_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_surg_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_surg_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_surg_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_surg_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_surg_20&NN._12);
data ibd_surg_20&NN.;
set ibd_surg_20&NN._01 - ibd_surg_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_surg_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_surg_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_surg_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_surg_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_surg_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_surg_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_surg_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_surg_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_surg_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_surg_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_surg_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_surg_20&NN._12);
data ibd_surg_20&NN.;
set ibd_surg_20&NN._01 - ibd_surg_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_surg_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_surg_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_surg_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_surg_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_surg_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_surg_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_surg_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_surg_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_surg_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_surg_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_surg_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_surg_20&NN._12);
data ibd_surg_20&NN.;
set ibd_surg_20&NN._01 - ibd_surg_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_surg_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_surg_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_surg_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_surg_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_surg_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_surg_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_surg_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_surg_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_surg_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_surg_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_surg_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_surg_20&NN._12);
data ibd_surg_20&NN.;
set ibd_surg_20&NN._01 - ibd_surg_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_surg_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_surg_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_surg_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_surg_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_surg_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_surg_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_surg_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_surg_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_surg_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_surg_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_surg_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_surg_20&NN._12);
data ibd_surg_20&NN.;
set ibd_surg_20&NN._01 - ibd_surg_20&NN._12;
yr_num=20&NN.;
run;

proc sort data=ibd_surg_2014; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_surg_2015; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_surg_2016; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_surg_2017; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_surg_2018; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_surg_2019; by &pat_idb &clm_beg_dt ; run;

data  &shlib..&temp_ds_pfx.temp_ibd_surg_ot (keep= &pat_id &flag_ibd_surg.:);
    set
     ibd_surg_2014
	 ibd_surg_2015
	 ibd_surg_2016
	 ibd_surg_2017
	 ibd_surg_2018
	 ibd_surg_2019
    ;
&flag_ibd_surg=1;
rename &clm_beg_dt = &flag_ibd_surg._dt;
run;

proc sort data= &shlib..&temp_ds_pfx.temp_ibd_surg_ot nodupkey
out=&shlib..&proj_ds_pfx.ibdsurg_ot_2014_2019;
by &pat_id &flag_ibd_surg._dt;
run;


/*
%macro SKot ;
/*count number of IBD hospitalizations from inpatient--this is for a check
	for final need to take into accunt study-specific 1st date*
*need to make bene_msis_st_id for this to run;
%macro counts (in=, date=, date_first=, date_last=, out=, flagin=, count=);
/*there should be no duplicates when this proc sort is run
    --if duplicates are deleted there is a problem above*
proc sort data=&in nodupkey;
by &pat_id &date ;
run;

data &out (keep = &pat_id &count &date_first &date_last);
set &in ;
by &pat_id &date;
where &flagin=1;

if first.&pat_id then do; &count = 0; &date_first=&date; end; &count + 1;
if last.&pat_id then do; &date_last=&date; end;
if last.&pat_id then output;
run;

proc freq data= &out ;
table &count;
run;
%field_numbers(inds=&out , vartochk= &count);
%mend;

%counts(in=&shlib..&proj_ds_pfx.ibdsurg_ot_2010_2015,
		out=ibd_hosp_ot_cnt , 
		date= ibd_surg_hosp_dt, 
		date_first=ibd_surg_hosp_dt_first,
		date_last=ibd_surg_hosp_dt_last,
		flagin=ibd_surg_hosp , count=ibd_surg_hosp_count );
