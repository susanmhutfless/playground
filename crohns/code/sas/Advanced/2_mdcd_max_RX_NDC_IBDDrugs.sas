/********************************************************************
* Job Name: 2_mdcd_max_RX_NDC_IBDDrugs.sas
* Job Desc: Identify prescription filles for drugs (by NDC code) in RX files
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
    %let    temp_ds_pfx = tmp_hcpcs_drug_;  /*** prefix to identify temp data
                                          leave the trailing underscore
										     ***/

    %global proj_ds_pfx;
    %let    proj_ds_pfx = max_    ;  /*** prefix for long term proj data
                                          leave the trailing underscore ***/

	%global def_proj_src_ds_prefix			;
	%let    def_proj_src_ds_prefix = max	;

%global final_sub_ds;
%let    final_sub_ds = &shlib..&proj_ds_pfx.ndc_drug_2010_2015; /*final permanent dataset*/


%let  pat_idb            = bene_id state_cd msis_id          ;
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
	--be careful!
proc datasets lib=&view_lib KILL; run; quit;*/


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
data ibd_drugs1; set ndc;
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
		if NONPROPRIETARYNAME in:( 'GOLIMUMAB') then do;
	   		drug_golim=1;
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
		if NONPROPRIETARYNAME in:( 'TOFACITINIB') then do;
	   		drug_tofa=1;
			drug_biologic=1;
			drug_jak=1;
		end;
		if NONPROPRIETARYNAME in:( 'UPADACITINIB') then do;
	   		drug_upa=1;
			drug_biologic=1;
			drug_jak=1;
		end;
		if NONPROPRIETARYNAME in:( 'OZANIMOD') then do;
	   		drug_oza=1;
			drug_biologic=1;
		end;
if drug_5asa=. and drug_steroids=. and drug_immunomodulator=. and drug_biologic=. then delete;
	run;
data ibd_drugs2; set ndc;
	where pharm_classes contains "ANTIBACTERIAL"; 
	drug_antibiotics=1;
run;

data ibd_drugs;
set ibd_drugs1
	ibd_drugs2;
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
 		ibd_drugs b
where a.ndc = b.ndc;
quit;

data    &view_lib..&prefix.data_&ctype.&state._&year.    /
          	view = &view_lib..&prefix.data_&ctype.&state._&year.    ;
set 	&view_lib..&prefix.NDCdrug&ctype.&state._&year.;
          ndc_dt = &ndc_dt; /*make generic name for drug administration for merging*/
          *drop &vars_to_drop_ip ;
		  if drug_inflix=1 then do;
             inflix=1; inflix_dt=ndc_dt;
         end;
         if drug_cert=1 then do;
             cert_peg=1; cert_peg_dt=ndc_dt;
         end;
         if drug_ada=1 then do;
             ada=1;	ada_dt=ndc_dt; label ada='adalimumab';
         end;
         if drug_natal then do;
             natal=1; natal_dt=ndc_dt;
         end;
         if drug_ust=1 then do;
             ustek=1; ustek_dt=ndc_dt;
         end;
         if drug_vedo=1 then do;
             vedo=1; vedo_dt=ndc_dt;
         end;
		if drug_golim=1 then do;
             golim=1; golim_dt=ndc_dt;
         end;
		 if drug_tofa=1 then do;
             tofa=1; tofa_dt=ndc_dt;
         end;
		 if drug_upa=1 then do;
             upa=1; upa_dt=ndc_dt;
         end;
		 if drug_oza=1 then do;
             oza=1; oza_dt=ndc_dt;
         end;
         if drug_steroids=1 then do;
             steroids=1; steroids_dt=ndc_dt;
         end;
         if drug_5asa=1 then do;
             asa=1; asa_dt=ndc_dt; label asa='5-asa';
         end;
		if drug_antibiotics=1 then do;
             antibiotic=1; antibiotic_dt=ndc_dt;
         end;
		 if drug_biologic=1 then do;
             biologic=1; biologic_dt=ndc_dt;
         end;
		 if drug_antiTNF=1 then do;
             antiTNF=1; antiTNF_dt=ndc_dt;
         end;
		 if drug_jak=1 then do;
             jak=1; jak_dt=ndc_dt;
         end;
		 if drug_immunomodulator=1 then do;
             immunomodulator=1; immunomodulator_dt=ndc_dt;
         end;
		 if drug_MTX=1 then do;
             mtx=1; mtx_dt=ndc_dt; label mtx='methotrexate';
         end;
		 if drug_AZA=1 then do;
             aza=1; aza_dt=ndc_dt; label aza='azathioprine';
         end;	
		 if drug_6mp=1 then do;
             sixmp=1; sixmp_dt=ndc_dt; label sixmp='6-mercaptopurine';
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
	 *if &pat_id=. then delete;
     run;

%mend;

%build_views(file_name_prefix = maxdata_  , file_type_code= ch , out_ds_combo= maxds_ndc_drug_   );

/*** here we take the final single view and actually initiate - pull the data from the views ***/
/*** into a single real sas dataset that we can then work with ***/

data final_sub_ds (drop = PRSCRPTN_FILL_DT);
    set sviews.maxds_ndc_drug_ch
        ;
format inflix_dt  cert_peg_dt  ada_dt  natal_dt  ustek_dt  vedo_dt steroids_dt asa_dt ndc_dt date9.;
run;

/*make permanent*/
data &final_sub_ds ; set final_sub_ds; run;

