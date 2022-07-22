/********************************************************************
* Job Name: 2_mdcd_taf_OP_HCPCS_IBDDrugs.sas
* Job Desc: Identify administration of drugs (by CPT/HCPCS code) in Outpatient
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
    %let    temp_ds_pfx = tmp_hcpcs_drug_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										    ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = taf_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.hcpcs_drug_ot_2014_2019;

%let  pat_idb            = bene_id  state_cd msis_id         ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global plc_of_srvc_cd  clm_beg_dt	hcpcs_cd hcpcs_dt         ;

%let  hcpcs_cd			 = line_prcdr_cd			;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;
%let  clm_beg_dt         = line_srvc_bgn_dt  	 ;
%let  hcpcs_dt 			  = hcpcs_dt		 ; *set to clm_beg_dt in code;

%global hcpcs_ada_criteria     ;
%global hcpcs_cert_peg_criteria;
%global hcpcs_inflix_criteria  ;
%global hcpcs_natal_criteria   ;
%global hcpcs_ustek_criteria   ;
%global hcpcs_vedo_criteria    ;
%global hcpcs_steroid_criteria	;
%global hcpcs_mtx_criteria		;
%global hcpcs_aza_criteria		;
%global hcpcs_drug_codes        ;

%let hcpcs_ada_criteria     = 'J0135'                        ;
%let hcpcs_cert_peg_criteria= 'J0717'                        ;
%let hcpcs_golim_criteria	= 'J1602'						 ;
%let hcpcs_inflix_criteria  = 'J1745' 'Q5102' 'Q5103' 'Q5104' 'Q5121'; *https://www.cms.gov/medicare-coverage-database/view/article.aspx?articleid=52423&ver=62&bc=CAAAAAAAAAAA;
%let hcpcs_natal_criteria   = 'J2323'                        ;
%let hcpcs_ustek_criteria   = 'J3357' 'J3358'                ;
%let hcpcs_vedo_criteria    = 'J3380'                        ;
*tofacitinib & Ozanimod do not have a specific cpt code: Prescription drug, oral, non-chemotherapeutic, Not otherwise specified;
%let hcpcs_nos_criteria	= 'J8499'						;
*upadacitinib does not have a cpt code, oral only;

%let hcpcs_cyclo_criteria	= 'J7502' 'J7515' 'J7516'		 ;
%let hcpcs_ritux_criteria	= 'J9310'						 ;
%let hcpcs_steroid_criteria = 'J1020' 'J1030' 'J1040' 'J2920' 'J2930' ;*NOT INCLUDING ORAL J7509, J7506, J7512;*Not including G codes or poisoning;
%let hcpcs_mtx_criteria		= 'J8610' 'J9250' 'J9260'		 ;
%let hcpcs_aza_criteria		= 'J7500' 'J7501'				 ;

%let hcpcs_drug_codes       = 	&hcpcs_ada_criteria
								&hcpcs_cert_peg_criteria
								&hcpcs_golim_criteria
								&hcpcs_inflix_criteria
                              &hcpcs_natal_criteria
                              &hcpcs_ustek_criteria
                              &hcpcs_vedo_criteria
							  &hcpcs_cyclo_criteria 
							  &hcpcs_ritux_criteria
							  &hcpcs_steroid_criteria
							  &hcpcs_mtx_criteria
							  &hcpcs_aza_criteria
                              ;


/*** end of section   - global vars ***/


%global def_proj_src_ds_prefix;
%let    def_proj_src_ds_prefix = taf;


/*** this section is related to IP - inpatient claims ***/
/*   get inpatient hcpcs_drug in hospital                   */


%macro ibdyear(serveryear=, ibdyear=);
		data    &ibdyear;
		          set &serveryear 
									(keep= &pat_idb 
								&clm_beg_dt 
								&hcpcs_cd ) ;
        where 
				&hcpcs_cd in ( &hcpcs_drug_codes ) ;
&hcpcs_dt = &clm_beg_dt; /*make generic name for drug administration for merging*/
	if &hcpcs_cd in (&hcpcs_ada_criteria)
    then do;
        ada           =1;
        ada_dt       =&clm_beg_dt;
		antiTNF=1; antiTNF_dt=&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if &hcpcs_cd in (&hcpcs_cert_peg_criteria)
    then do;
        cert_peg           =1;
        cert_peg_dt       =&clm_beg_dt;
		antiTNF=1; antiTNF_dt=&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if &hcpcs_cd in (&hcpcs_golim_criteria)
    then do;
        golim          =1;
        golim_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if &hcpcs_cd in (&hcpcs_inflix_criteria)
    then do;
        inflix           =1;
        inflix_dt       =&clm_beg_dt;
		antiTNF=1; antiTNF_dt=&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if &hcpcs_cd in (&hcpcs_natal_criteria)
    then do;
        natal          =1;
        natal_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if &hcpcs_cd in (&hcpcs_ustek_criteria)
    then do;
        ustek           =1;
        ustek_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;
	if &hcpcs_cd in (&hcpcs_vedo_criteria)
    then do;
        vedo           =1;
        vedo_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;
	if &hcpcs_cd in (&hcpcs_steroid_criteria)
    then do;
		steroids		=1;
		steroids_dt		=&clm_beg_dt;
    end;        
	if &hcpcs_cd in (&hcpcs_mtx_criteria)
    then do;
		mtx		=1;
		mtx_dt		=&clm_beg_dt;
		immunomodulator=1; immunomodulator_dt=&clm_beg_dt;
    end;        
	if &hcpcs_cd in (&hcpcs_aza_criteria)
    then do;
		aza		=1;
		aza_dt		=&clm_beg_dt;
		immunomodulator=1; immunomodulator_dt=&clm_beg_dt;
    end;  

	if &hcpcs_cd in (&hcpcs_cyclo_criteria )
    then do;
		cyclo		=1;
		cyclo_dt		=&clm_beg_dt;
		immunomodulator=1; immunomodulator_dt=&clm_beg_dt;
    end; 
     run;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_op_drug_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_op_drug_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_op_drug_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_op_drug_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_op_drug_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_op_drug_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_op_drug_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_op_drug_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_op_drug_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_op_drug_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_op_drug_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_op_drug_20&NN._12);
data ibd_op_drug_20&NN.;
set ibd_op_drug_20&NN._01 - ibd_op_drug_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_op_drug_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_op_drug_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_op_drug_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_op_drug_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_op_drug_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_op_drug_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_op_drug_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_op_drug_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_op_drug_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_op_drug_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_op_drug_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_op_drug_20&NN._12);
data ibd_op_drug_20&NN.;
set ibd_op_drug_20&NN._01 - ibd_op_drug_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_op_drug_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_op_drug_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_op_drug_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_op_drug_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_op_drug_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_op_drug_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_op_drug_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_op_drug_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_op_drug_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_op_drug_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_op_drug_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_op_drug_20&NN._12);
data ibd_op_drug_20&NN.;
set ibd_op_drug_20&NN._01 - ibd_op_drug_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_op_drug_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_op_drug_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_op_drug_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_op_drug_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_op_drug_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_op_drug_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_op_drug_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_op_drug_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_op_drug_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_op_drug_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_op_drug_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_op_drug_20&NN._12);
data ibd_op_drug_20&NN.;
set ibd_op_drug_20&NN._01 - ibd_op_drug_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_op_drug_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_op_drug_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_op_drug_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_op_drug_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_op_drug_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_op_drug_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_op_drug_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_op_drug_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_op_drug_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_op_drug_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_op_drug_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_op_drug_20&NN._12);
data ibd_op_drug_20&NN.;
set ibd_op_drug_20&NN._01 - ibd_op_drug_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..other_services_line_01, ibdyear=ibd_op_drug_20&NN._01);
%ibdyear(serveryear=tafr&NN..other_services_line_02, ibdyear=ibd_op_drug_20&NN._02);
%ibdyear(serveryear=tafr&NN..other_services_line_03, ibdyear=ibd_op_drug_20&NN._03);
%ibdyear(serveryear=tafr&NN..other_services_line_04, ibdyear=ibd_op_drug_20&NN._04);
%ibdyear(serveryear=tafr&NN..other_services_line_05, ibdyear=ibd_op_drug_20&NN._05);
%ibdyear(serveryear=tafr&NN..other_services_line_06, ibdyear=ibd_op_drug_20&NN._06);
%ibdyear(serveryear=tafr&NN..other_services_line_07, ibdyear=ibd_op_drug_20&NN._07);
%ibdyear(serveryear=tafr&NN..other_services_line_08, ibdyear=ibd_op_drug_20&NN._08);
%ibdyear(serveryear=tafr&NN..other_services_line_09, ibdyear=ibd_op_drug_20&NN._09);
%ibdyear(serveryear=tafr&NN..other_services_line_10, ibdyear=ibd_op_drug_20&NN._10);
%ibdyear(serveryear=tafr&NN..other_services_line_11, ibdyear=ibd_op_drug_20&NN._11);
%ibdyear(serveryear=tafr&NN..other_services_line_12, ibdyear=ibd_op_drug_20&NN._12);
data ibd_op_drug_20&NN.;
set ibd_op_drug_20&NN._01 - ibd_op_drug_20&NN._12;
yr_num=20&NN.;
run;

proc sort data=ibd_op_drug_2014; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_op_drug_2015; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_op_drug_2016; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_op_drug_2017; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_op_drug_2018; by &pat_idb &clm_beg_dt ; run;
proc sort data=ibd_op_drug_2019; by &pat_idb &clm_beg_dt ; run;

data  &temp_ds_pfx._ot ;
    set
     ibd_op_drug_2014
	 ibd_op_drug_2015
	 ibd_op_drug_2016
	 ibd_op_drug_2017
	 ibd_op_drug_2018
	 ibd_op_drug_2019
    ;
run;

proc sort data= &temp_ds_pfx._ot  nodupkey
out=&shlib..&proj_ds_pfx.hcpcs_drug_ot_2014_2019;
by &pat_id &clm_beg_dt;
run;


/*
%macro SKIP ;
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

%counts(in=&shlib..&proj_ds_pfx.hcpcs_drug_ot_2010_2015,
		out=ibd_hosp_ip_cnt , 
		date= ibd_op_drug_hosp_dt, 
		date_first=ibd_op_drug_hosp_dt_first,
		date_last=ibd_op_drug_hosp_dt_last,
		flagin=ibd_op_drug_hosp , count=ibd_op_drug_hosp_count );
