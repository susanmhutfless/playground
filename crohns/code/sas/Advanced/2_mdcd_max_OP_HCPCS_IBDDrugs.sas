/********************************************************************
* Job Name: 2_mdcd_max_OP_HCPCS_IBDDrugs.sas
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
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

	%global def_proj_src_ds_prefix			;
	%let    def_proj_src_ds_prefix = max	;

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.hcpcs_drug_ot_2010_2015; /*final permanent dataset*/

%let  pat_idb            = bene_Id state_cd msis_id          ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;


%global proc_pfx proc_cd_min proc_cd_max 	 ;
%global plc_of_srvc_cd  clm_beg_dt	         ;

%let  hcpcs_cd			 = prcdr_cd			;
%let  plc_of_srvc_cd     = plc_of_srvc_cd    ;
%let  clm_beg_dt         = srvc_bgn_dt  	 ;
%let  hcpcs_dt 			  = hcpcs_dt		 ; *set to clm_beg_dt in code;


%global ds_all_prefix                    	 ;
%let  ds_all_prefix      = cd_ip_h_2010_15_all	;
%let  ds_all_hop         = &shlib..&ds_all_prefix.	;


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

%global year_1 year_2 year_3 year_4 year_5 year_6;
%let year_1 =2010;
%let year_2 =2011;
%let year_3 =2012;
%let year_4 =2013;
%let year_5 =2014;
%let year_6 =2015;


/*this program uses views--delete ALL existing tables in views library
before begining to minimize mistakes*/
proc datasets lib=&view_lib; delete _all_; run;

/*** this section is related to HCPCS criteria for drugs - outpatient claims ***/

%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  state          = ,
                  ctype          = );

     data        &view_lib..&prefix.data_&ctype.&state._&year.    /
          view = &view_lib..&prefix.data_&ctype.&state._&year.    ;
          set &src_lib_prefix.&year..&prefix.data&state._&ctype._&year  
								(keep= &pat_idb  &clm_dob 
								&clm_beg_dt &clm_end_dt
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

/*** macro that calls views - runs by year and state loops ***/
%macro make_views_dsk(y_list     =,
                      m_list     =,
                      ctype      = );
     %let year_idx=1;
     %let year_to_do= %scan(&y_list        ,  &year_idx);
     %do %while (&year_to_do   ne);

         %let st_idx=1;
         %let st_to_do=%scan( &m_list  , &st_idx);
             %do %while ( &st_to_do   ne);

                     %create_dsk(view_lib      = &view_lib                ,
                                 src_lib_prefix= &def_proj_src_ds_prefix  ,
                                 year          = &year_to_do              ,
                                 prefix        = &def_proj_src_ds_prefix  ,
                                 state         = &st_to_do                ,
                                 ctype         = &ctype         );

                 %let st_idx   = %eval( &st_idx + 1);
                 %let st_to_do = %scan( &m_list , &st_idx );
             %end;
         %let year_idx   = %eval( &year_idx + 1 );
         %let year_to_do = %scan( &y_list, &year_idx );
     %end;
%mend;




/*** overall driver macro that allows us to configure which year and state to spin thru ***/
/*** this macro also does a clean up first by removing and deleting pre existing views  ***/
/*** its important to NEVER mix up project views in view folders to ensure safety       ***/
/*** its also important to never mix real sas data with sas views in this type of method***/

%macro build_views(file_name_prefix = ,
                   file_type_code   = ,
                   out_ds_combo     = );
     proc datasets lib= &view_lib noprint ;
         delete  &file_name_prefix.&file_type_code._:   (memtype = view);
         delete  &out_ds_combo.&file_type_code          (memtype = view);
     quit;
     run;


      /*** here we custom configure which year, state we want to spin thru   ***/
      /*** note for each state the _ prefix - this is due to how macro       ***/
      /*** interprets the state of oregon 'o r' as actual syntax and falters ***/
      /*** the underscore prefix quickly solves that but i'll find a better  ***/
      /*** solution later ***/
     %make_views_dsk(y_list= 2010      2012 2013 2014 2015 , m_list= _id                  , ctype= ot );
	  	%make_views_dsk(y_list=      2011 2012 2013           , m_list= _ak _al _co _dc _de _fl _il 
																		_ks _md _me _mt
																		_nc _nd _ny _ne _nh _nm _nv 
																		_ri _wi, ctype= ot );  

        %make_views_dsk(y_list= 2010 2011 2012 2013 2014      , m_list=  _az _ct _hi _ky _in _ma																		
																	     _oh _ok _or _sc _tx _va _wa , ctype= ot );
		%make_views_dsk(y_list= 2010 2011 2012 2013 2014 2015 , m_list=  _ar  
																 _ca  _ct   
																  _ga  _ia    
																      _la       _mi
                                                                 _mn _mo _ms   _nj  _ny   _or _pa
                                                                   _sd _tn  _ut  _vt
																   _wv _wy      , ctype= ot );

     /*** here we combine all the individual "views" into a single bigger "view" ***/
     data        &view_lib..&out_ds_combo.&file_type_code   /
          view = &view_lib..&out_ds_combo.&file_type_code   ;
          set sviews.maxdata_ot: ;
	 hcpcs_cd=prcdr_cd;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_hcpcs_ot_   );

/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data final_sub_ds (drop = prcdr_cd &clm_beg_dt);
    set sviews.maxds_hcpcs_ot_ch
        ;
   *where biologic_dt ne . OR steroids_dt ne . OR immunomodulator_dt ne .;
format hcpcs_dt inflix_dt  cert_peg_dt  ada_dt  natal_dt  ustek_dt  vedo_dt
		steroids_dt immunomodulator_dt antiTNF_dt biologic_dt date9.;
run;
data &final_sub_ds (drop = hcpcs_cd); set final_sub_ds; run;

proc print data=&final_sub_ds (obs=10); where steroids_dt ne .; run;
