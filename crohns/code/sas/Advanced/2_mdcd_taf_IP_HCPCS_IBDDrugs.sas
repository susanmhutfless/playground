/********************************************************************
* Job Name: 2_mdcd_taf_IP_HCPCS_IBDDrugs.sas
* Job Desc: Identify administration of drugs (by CPT/HCPCS code) in Inpatient
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
    %let    temp_ds_pfx = tmp_hosp_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										  hosp stands for ibd surgery  ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = taf_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/
	%global def_proj_src_ds_prefix;
	%let    def_proj_src_ds_prefix = taf;

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.hcpcs_drug_ip_2014_2019;

%let  pat_idb            = bene_Id state_cd msis_id          ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;


%global proc_pfx proc_cd_min proc_cd_max 	 ;
%global plc_of_srvc_cd  clm_beg_dt	         ;

%let  proc_pfx           = prcdr_cd_         ;
%let  proc_cd_min        = 1                 ;
%let  proc_cd_max        = 6                 ;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;
%let  clm_beg_dt         = srvc_bgn_dt  	 ;
%let  hcpcs_dt 			  = hcpcs_dt		 ; *set to clm_beg_dt in code;


%global ds_all_prefix                    	 ;
%let  ds_all_prefix      = cd_ip_h_2010_15_all	;
%let  ds_all_hop         = &shlib..&ds_all_prefix.	;

*GOOD SOURCE: https://hcpcscodes.org/jcodes;
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




/*** this section is related to IP - inpatient claims ***/
/*   get inpatient IBD hospitalizations                   */

%macro ibdyear(serveryear=, ibdyear=);
		data    &ibdyear;
		          set &serveryear 
						(keep= &pat_idb   &clm_dob 
								&CLM_ADMSN_DT &clm_beg_dt &clm_end_dt
								&diag_pfx.: &proc_pfx.: );
          where 
				&proc_pfx.1 in ( &hcpcs_drug_codes ) or
                &proc_pfx.2 in ( &hcpcs_drug_codes ) or
                &proc_pfx.3 in ( &hcpcs_drug_codes ) or
                &proc_pfx.4 in ( &hcpcs_drug_codes ) or
                &proc_pfx.5 in ( &hcpcs_drug_codes ) or
                &proc_pfx.6 in ( &hcpcs_drug_codes );
&hcpcs_dt = &clm_beg_dt; /*make generic name for drug administration for merging*/
array proc(&proc_cd_max.) &proc_pfx.1 - &proc_pfx.&proc_cd_max.;
  	do i=1 to &proc_cd_max.;
   
	if proc(i) in (&hcpcs_ada_criteria)
    then do;
        ada           =1;
        ada_dt       =&clm_beg_dt;
		antiTNF=1; antiTNF_dt=&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if proc(i) in (&hcpcs_cert_peg_criteria)
    then do;
        cert_peg           =1;
        cert_peg_dt       =&clm_beg_dt;
		antiTNF=1; antiTNF_dt=&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if proc(i) in (&hcpcs_golim_criteria)
    then do;
        golim          =1;
        golim_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if proc(i) in (&hcpcs_inflix_criteria)
    then do;
        inflix           =1;
        inflix_dt       =&clm_beg_dt;
		antiTNF=1; antiTNF_dt=&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if proc(i) in (&hcpcs_natal_criteria)
    then do;
        natal          =1;
        natal_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;

	if proc(i) in (&hcpcs_ustek_criteria)
    then do;
        ustek           =1;
        ustek_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;
	if proc(i) in (&hcpcs_vedo_criteria)
    then do;
        vedo           =1;
        vedo_dt       =&clm_beg_dt;
		biologic=1; biologic_dt=&clm_beg_dt;
    end;
	if proc(i) in (&hcpcs_steroid_criteria)
    then do;
		steroids		=1;
		steroids_dt		=&clm_beg_dt;
    end;        
	if proc(i) in (&hcpcs_mtx_criteria)
    then do;
		mtx		=1;
		mtx_dt		=&clm_beg_dt;
		immunomodulator=1; immunomodulator_dt=&clm_beg_dt;
    end;        
	if proc(i) in (&hcpcs_aza_criteria)
    then do;
		aza		=1;
		aza_dt		=&clm_beg_dt;
		immunomodulator=1; immunomodulator_dt=&clm_beg_dt;
    end;  

	if proc(i) in (&hcpcs_cyclo_criteria )
    then do;
		cyclo		=1;
		cyclo_dt		=&clm_beg_dt;
		immunomodulator=1; immunomodulator_dt=&clm_beg_dt;
    end; 
end; 
     run;
%mend;
%let NN=14;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=hcpcs_drug_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=hcpcs_drug_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=hcpcs_drug_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=hcpcs_drug_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=hcpcs_drug_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=hcpcs_drug_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=hcpcs_drug_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=hcpcs_drug_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=hcpcs_drug_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=hcpcs_drug_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=hcpcs_drug_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=hcpcs_drug_ip_20&NN._12);
data hcpcs_drug_ip_20&NN.;
set hcpcs_drug_ip_20&NN._01 - hcpcs_drug_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=15;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=hcpcs_drug_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=hcpcs_drug_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=hcpcs_drug_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=hcpcs_drug_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=hcpcs_drug_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=hcpcs_drug_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=hcpcs_drug_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=hcpcs_drug_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=hcpcs_drug_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=hcpcs_drug_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=hcpcs_drug_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=hcpcs_drug_ip_20&NN._12);
data hcpcs_drug_ip_20&NN.;
set hcpcs_drug_ip_20&NN._01 - hcpcs_drug_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=16;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=hcpcs_drug_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=hcpcs_drug_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=hcpcs_drug_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=hcpcs_drug_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=hcpcs_drug_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=hcpcs_drug_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=hcpcs_drug_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=hcpcs_drug_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=hcpcs_drug_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=hcpcs_drug_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=hcpcs_drug_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=hcpcs_drug_ip_20&NN._12);
data hcpcs_drug_ip_20&NN.;
set hcpcs_drug_ip_20&NN._01 - hcpcs_drug_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=17;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=hcpcs_drug_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=hcpcs_drug_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=hcpcs_drug_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=hcpcs_drug_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=hcpcs_drug_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=hcpcs_drug_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=hcpcs_drug_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=hcpcs_drug_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=hcpcs_drug_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=hcpcs_drug_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=hcpcs_drug_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=hcpcs_drug_ip_20&NN._12);
data hcpcs_drug_ip_20&NN.;
set hcpcs_drug_ip_20&NN._01 - hcpcs_drug_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=18;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=hcpcs_drug_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=hcpcs_drug_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=hcpcs_drug_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=hcpcs_drug_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=hcpcs_drug_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=hcpcs_drug_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=hcpcs_drug_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=hcpcs_drug_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=hcpcs_drug_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=hcpcs_drug_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=hcpcs_drug_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=hcpcs_drug_ip_20&NN._12);
data hcpcs_drug_ip_20&NN.;
set hcpcs_drug_ip_20&NN._01 - hcpcs_drug_ip_20&NN._12;
yr_num=20&NN.;
run;
%let NN=19;
%ibdyear(serveryear=tafr&NN..inpatient_header_01, ibdyear=hcpcs_drug_ip_20&NN._01);
%ibdyear(serveryear=tafr&NN..inpatient_header_02, ibdyear=hcpcs_drug_ip_20&NN._02);
%ibdyear(serveryear=tafr&NN..inpatient_header_03, ibdyear=hcpcs_drug_ip_20&NN._03);
%ibdyear(serveryear=tafr&NN..inpatient_header_04, ibdyear=hcpcs_drug_ip_20&NN._04);
%ibdyear(serveryear=tafr&NN..inpatient_header_05, ibdyear=hcpcs_drug_ip_20&NN._05);
%ibdyear(serveryear=tafr&NN..inpatient_header_06, ibdyear=hcpcs_drug_ip_20&NN._06);
%ibdyear(serveryear=tafr&NN..inpatient_header_07, ibdyear=hcpcs_drug_ip_20&NN._07);
%ibdyear(serveryear=tafr&NN..inpatient_header_08, ibdyear=hcpcs_drug_ip_20&NN._08);
%ibdyear(serveryear=tafr&NN..inpatient_header_09, ibdyear=hcpcs_drug_ip_20&NN._09);
%ibdyear(serveryear=tafr&NN..inpatient_header_10, ibdyear=hcpcs_drug_ip_20&NN._10);
%ibdyear(serveryear=tafr&NN..inpatient_header_11, ibdyear=hcpcs_drug_ip_20&NN._11);
%ibdyear(serveryear=tafr&NN..inpatient_header_12, ibdyear=hcpcs_drug_ip_20&NN._12);
data hcpcs_drug_ip_20&NN.;
set hcpcs_drug_ip_20&NN._01 - hcpcs_drug_ip_20&NN._12;
yr_num=20&NN.;
run;


data &final_sub_ds (drop = i &diag_pfx.: &proc_pfx.:);
set
     hcpcs_drug_ip_2014
	 hcpcs_drug_ip_2015
	 hcpcs_drug_ip_2016
	 hcpcs_drug_ip_2017
	 hcpcs_drug_ip_2018
	 hcpcs_drug_ip_2019
    ;
run;
*shu172sl.taf_hcpcs_drug_ip_2010_2015;
