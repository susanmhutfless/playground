/********************************************************************
* Job Name: 2_mdcd_max_RX_NDC_TPN.sas
* Job Desc: Identify prescription fills for TPN drugs (by NDC code) in RX files
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab
********************************************************************/

/** alert - the job and settings in 0_setup_facts.sas must be set first **/

/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;
%global pat_idb clm_id                       ;
%global pat_id                               ;

%let  lwork              = work              ;
%let  ltemp              = temp              ;
%let  shlib              = shu172sl          ;

    %global temp_ds_pfx;
    %let    temp_ds_pfx = tmp_tpn_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										   tpn stands for total pareternal nutrition  ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

	%global def_proj_src_ds_prefix			;
	%let    def_proj_src_ds_prefix = max	;

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.ndc_tpn_2010_2015; /*final permanent dataset*/


%let  pat_idb            = bene_id state_cd msis_id            ;
%let  pat_id             = &pat_idb          ;
%let  clm_id             = clm_id            ;

%global ndc_var ndc_date;
%let    ndc_var        = ndc;
%let    ndc_dt         = PRSCRPTN_FILL_DT;
%global all_rx_vars ;
%let    all_rx_vars    = &pat_id &ndc_var &ndc_dt ;

%global year_1 year_2 year_3 year_4 year_5 year_6;
%let year_1 =2010;
%let year_2 =2011;
%let year_3 =2012;
%let year_4 =2013;
%let year_5 =2014;
%let year_6 =2015;

/*** end of section   - global vars ***/

/*this program uses views--delete ALL existing tables in views library
before begining to minimize mistakes*/
/*if you are running multiple programs at once, this step can mess up that work
	--be careful!*/
/*proc datasets lib=&view_lib KILL; run; quit;*/


/*the medicaid RX files have NDC but not the drug names
	it is much easier to search by drug name*/
	/**Download the product and package files from FDA that have brand/generic names (finished products)
		https://www.fda.gov/drugs/drug-approvals-and-databases/national-drug-code-directory
		Note: The product and package files are updated regularly. This
			study's downloaded files may be out of date**/
data package;
set &shlib..ndc_package;
seg1 = input(scan(NDCPACKAGECODE, 1), 8.);
seg2 = input(scan(NDCPACKAGECODE, 2), 8.);
seg3 = input(scan(NDCPACKAGECODE, 3), 8.);
productndc11 = catx("-", put(seg1, z5.), put(seg2, z4.), put(seg3, z2.)); 
ndc=cat(put(seg1, z5.), put(seg2, z4.), put(seg3, z2.));
run;
proc sort data=&shlib..ndc_product; by productid productndc;
proc sort data=package; by productid productndc;
data ndc (keep= ndc nonproprietaryname proprietaryname pharm_classes);
merge package (in=a) &shlib..ndc_product (in=b);
by productid productndc;
if a and b;
	   nonproprietaryname = upcase(nonproprietaryname);
	   proprietaryname = upcase(proprietaryname);
	   pharm_classes = upcase(pharm_classes);
run;
data tpn_drugs1; set ndc;
/*make labels for TPN drugs of interest based on pharm classes & proprietary name*/
		if pharm_classes in(
			"LIPID EMULSION [EPC],LIPIDS [CS]"
			"AMINO ACID [EPC],AMINO ACIDS [CS]"
			"LIPID EMULSION [EPC],LIPIDS [CS]"	
			)
		then tpn=1;
	   	if PROPRIETARYNAME = 'CLINIMIX E'
	   	then tpn=1;
if tpn=. then delete;
	run;

data tpn_drugs;
set tpn_drugs1;
run;


%macro create_dsk(view_lib       = ,
                  src_lib_prefix = ,
                  year           = ,
                  prefix         = ,
                  state          = ,
                  ctype          = );

     data        &view_lib..&prefix.RXdrug&ctype.&state._&year.    /
          view = &view_lib..&prefix.RXdrug&ctype.&state._&year.    ;
          set
			&src_lib_prefix.&year..&prefix.data&state._&ctype._&year  (keep= &all_rx_vars )	; 
	run;

proc sql;
create table &view_lib..&prefix.NDCdrug&ctype.&state._&year. (compress=yes) as
select * 
 FROM   &view_lib..&prefix.RXdrug&ctype.&state._&year. a,
 		tpn_drugs b
where a.ndc = b.ndc;
quit;

data    &view_lib..&prefix.data_&ctype.&state._&year.    /
          	view = &view_lib..&prefix.data_&ctype.&state._&year.    ;
set 	&view_lib..&prefix.NDCdrug&ctype.&state._&year.;
          ndc_dt = &ndc_dt; /*make generic name for drug administration for merging*/
          *drop &vars_to_drop_ip ;
		  if tpn=1 then do;
             tpn_dt=ndc_dt;
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
     %make_views_dsk(y_list= 2010      2012 2013 2014 2015 , m_list= _id                  , ctype= rx );
	  	%make_views_dsk(y_list=      2011 2012 2013           , m_list= _ak _al _co _dc _de _fl _il 
																		_ks _md _me _mt
																		_nc _nd _ny _ne _nh _nm _nv 
																		_ri _wi, ctype= rx );  

        %make_views_dsk(y_list= 2010 2011 2012 2013 2014      , m_list=  _az _ct _hi _ky _in _ma																		
																	     _oh _ok _or _sc _tx _va _wa , ctype= rx );
		%make_views_dsk(y_list= 2010 2011 2012 2013 2014 2015 , m_list=  _ar  
																 _ca  _ct   
																  _ga  _ia    
																      _la       _mi
                                                                 _mn _mo _ms   _nj  _ny   _or _pa
                                                                   _sd _tn  _ut  _vt
																   _wv _wy      , ctype= rx );




     /*** here we combine all the individual "views" into a single bigger "view" ***/
     data        &view_lib..&out_ds_combo.&file_type_code   /
          view = &view_lib..&out_ds_combo.&file_type_code   ;
          set sviews.maxdata_rx: ;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_ndc_tpn_   );

/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data final_sub_ds (drop = PRSCRPTN_FILL_DT);
    set sviews.maxds_ndc_tpn_ch
        ;
format tpn_dt ndc_dt date9.;
run;

/*make permanent*/
data &final_sub_ds ; set final_sub_ds; run;

