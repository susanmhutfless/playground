/********************************************************************
* Job Name: read_raw_ndc_product.sas
* Job Desc: code to read raw txt related to ndc - specific to product
*           data and fields.
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************/

%global  raw_data_path     ;
%global  raw_data_product  ;
%global  raw_product       ;
%let     raw_data_path     = /*C:\z_data\z_client_jhu\ndc\;*/ S:\CMS\CMS synth data\;
%let     raw_data_product  = ndc_product.txt;
%let     raw_product       = &raw_data_path.&raw_data_product;


%global  perm_lib          ;
%global  lwork             ;
%global  out_ds            ;
%global  out_ds_to_scan    ;
%let     perm_lib          =ndcprod        ;
%let     lwork             =work           ;
%let     out_ds            =ndc_product    ;
%let     out_ds_to_scan    =ndc_prod_scan  ;

libname &perm_lib "C:\z_data\z_client_jhu\ndc_puf_short_term";

%global  prod_id           ;
%global  prod_ndc          ;
%let     prod_id           =productid      ;
%let     prod_ndc          =productndc     ;


%macro read_in_raw_to_get_sasds(raw_in_data   = ,
                                local_out_ds  = ,
                                local_prod_id = ,
                                local_prod_ndc= );
   data &local_out_ds ;
       infile "&raw_in_data"
       delimiter='09'x MISSOVER DSD lrecl=32767 firstobs=2 ;

       /*** these are fields in the ndc product table raw data ***/
       /*** these are properties of the fields as observed on  ***/
       /*** or about 2019/11 - if the file, fields are updated ***/
       /*** you will need to re/verify field properties        ***/

          /*** the informat and format are not related to the sequence of columns in data ***/
          informat &local_prod_id                    $46.  ; format &local_prod_id               $46.  ;
          informat &local_prod_ndc                   $10.  ; format &local_prod_ndc              $10.  ;
          informat product_type_nm                   $30.  ; format product_type_nm              $30.  ;
          informat proprietary_nm                   $200.  ; format proprietary_nm              $200.  ;
          informat proprietary_nm_sfx               $200.  ; format proprietary_nm_sfx          $200.  ;
          informat non_proprietary_nm               $600.  ; format non_proprietary_nm          $600.  ;
          informat dosage_form_nm                    $50.  ; format dosage_form_nm               $50.  ;
          informat route_nm                         $100.  ; format route_nm                    $100.  ;
          informat market_beg_dt              anydtdte21.  ; format market_beg_dt            yymmdd10. ;
          informat market_end_dt              anydtdte21.  ; format market_end_dt            yymmdd10. ;
          informat market_cat_nm                     $50.  ; format market_cat_nm                $50.  ;
          informat app_number                        $15.  ; format app_number                   $15.  ;
          informat labeler_nm                       $150.  ; format labeler_nm                  $150.  ;
          informat substance_nm                    $4000.  ; format substance_nm               $4000.  ;
          informat active_numert_strn               $800.  ; format active_numert_strn          $800.  ;
          informat active_ingred_unit              $3000.  ; format active_ingred_unit         $3000.  ;
          informat pharm_classes                    $150.  ; format pharm_classes               $150.  ;
          informat dea_schedule                       $5.  ; format dea_schedule                  $5.  ;
          informat ndc_exclude_flag                   $1.  ; format ndc_exclude_flag              $1.  ;
          informat listing_rec_cert_thru      anydtdte21.  ; format listing_rec_cert_thru    yymmdd10. ;

       /*** the input section and sequence is related to column and raw data sequence ***/
       /*** the field sequence and list of fields here in input section must be verified ***/
       input
          &local_prod_id             $
          &local_prod_ndc            $
          product_type_nm            $
          proprietary_nm             $
          proprietary_nm_sfx         $
          non_proprietary_nm         $
          dosage_form_nm             $
          route_nm                   $
          market_beg_dt
          market_end_dt
          market_cat_nm              $
          app_number                 $
          labeler_nm                 $
          substance_nm               $
          active_numert_strn         $
          active_ingred_unit         $
          pharm_classes              $
          dea_schedule               $
          ndc_exclude_flag           $
          listing_rec_cert_thru
       ;

       /*** var - field prep ***/
       /*** actions performed on these vars must also be done ***/
       /*** on any other table of data with same vars and     ***/
       /*** especially if you will merge or join tables       ***/
       /*** these same actions will be set on ndc Package     ***/
       &local_prod_id   =upcase(&local_prod_id       );
       &local_prod_ndc  =upcase(&local_prod_ndc      );
       &local_prod_ndc  =compress(&local_prod_ndc,'-');
   run;

    proc sort data= &local_out_ds ;
    by   &local_prod_id  &local_prod_ndc   market_beg_dt market_end_dt ;
    run;

%mend; *** end of read_in_raw_to_get_sasds ;



%macro prep_fields_to_use(local_in_ds  =,
                          local_out_ds =);
    data &local_out_ds  ;
     set &local_in_ds ;
        /*** set field values to consistent upper case       ***/
        /*** these are fields we will/can use for ident work ***/
        proprietary_nm     =upcase(proprietary_nm     );
        non_proprietary_nm =upcase(non_proprietary_nm );
        substance_nm       =upcase(substance_nm       );
        pharm_classes      =upcase(pharm_classes      );
    run;
%mend;


%macro drop_unused_fields(local_in_ds  =,
                          local_out_ds =,
                          vars_to_drop =);

    data &local_out_ds  ;
        set &local_in_ds ;
        /*** fields we do not need in most work for 2019/11 ***/
        drop &vars_to_drop         ;
        drop market_cat_nm         ;
        drop dosage_form_nm        ;
        drop proprietary_nm_sfx    ;
        drop active_numert_strn    ;
        drop active_ingred_unit    ;
        drop product_type_nm       ;
        drop labeler_nm            ;
        drop route_nm              ;
        drop dea_schedule          ;
        drop ndc_exclude_flag      ;
        drop listing_rec_cert_thru ;
        drop market_beg_dt         ;
        drop market_end_dt         ;
        drop app_number            ;
    run;

%mend;


%macro prep_fields_to_scan(local_in_ds  =,
                           local_out_ds =);

    data &local_out_ds  ;
     set &local_in_ds ;
         /*** create one long wide var to use for scanning of text ***/
         length var_to_scan $8000.;
         var_to_scan=trimn(proprietary_nm)     !! '-' !!
                     trimn(non_proprietary_nm) !! '-' !!
                     trimn(substance_nm)       !! '-' !!
                     trimn(pharm_classes);
         drop substance_nm       ;
         drop proprietary_nm     ;
         drop non_proprietary_nm ;
    run;

%mend;



%read_in_raw_to_get_sasds(raw_in_data   = &raw_product,
                          local_out_ds  = &perm_lib..&out_ds,
                          local_prod_id = &prod_id ,
                          local_prod_ndc= &prod_ndc
                          );


%prep_fields_to_use(local_in_ds  =&perm_lib..&out_ds,
                    local_out_ds =&perm_lib..&out_ds_to_scan
                    );

%drop_unused_fields(local_in_ds  =&perm_lib..&out_ds_to_scan,
                    local_out_ds =&perm_lib..&out_ds_to_scan,
                    vars_to_drop =
                         market_cat_nm
                         dosage_form_nm
                         proprietary_nm_sfx
                         active_numert_strn
                         active_ingred_unit
                         product_type_nm
                         labeler_nm
                         route_nm
                         dea_schedule
                         ndc_exclude_flag
                         listing_rec_cert_thru
                         market_beg_dt
                         market_end_dt
                         app_number
                    );


%prep_fields_to_scan(local_in_ds  =&perm_lib..&out_ds_to_scan,
                     local_out_ds =&perm_lib..&out_ds_to_scan );



proc sort data=&perm_lib..&out_ds_to_scan ;
by  &prod_id  &prod_ndc  ;
run;

proc sort data=&perm_lib..&out_ds_to_scan nodupkey;
by  &prod_id  &prod_ndc  ;
run;
