/********************************************************************
* Job Name: scan_ndc_data_for_products.sas
* Job Desc:
*
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************/

%global  perm_lib          ;
%global  lwork             ;
%global  in_ndc_ds         ;

%let     perm_lib          =ndcprod        ;
%let     lwork             =work           ;
%let     in_ndc_ds         =ndc_prod_scan  ;

libname &perm_lib "C:\z_data\z_client_jhu\ndc_puf_short_term";

%global  prod_id           ;
%global  prod_ndc          ;
%let     prod_id           =productid      ;
%let     prod_ndc          =productndc     ;

%global  def_path          ;
%let     def_path          =C:\z__projects\jhu_puf\crohnsPUF\code\definitions\;

%global  out_ds_prod_cats  ;
%global  out_ds_prod_nm    ;
%let     out_ds_prod_nm    =ndc_prod_cats ;
%let     out_ds_prod_cats  =&perm_lib..&out_ds_prod_nm;

%global  med_ndc_pfx       ;
%let     med_ndc_pfx       = ttl_ ; /** prefix analyst used for med, product pharma flags **/

/*** code to scan output of ndc product for various drugs we are interested in ***/
/*** you need 1 marco statement per drug of interest ***/
/*** make sure to run this macro first:
     ...code\sas\macro_ndc_char_scan_for_drug_name.sas
**********************************************************************************/
%include "C:\z__projects\jhu_puf\crohnsPUF\code\sas\macro_ndc_char_scan_for_drug_name.sas";
    /*** output ds name is:   libname(dot) local_out_ds "_" drug_main_cat_name ***/
    /*** there will be a single underscore before "drug_main_cat_name" added   ***/


%macro scan_various(out_ds_prefix=  /*** can not exceed  5 bytes ***/,
                    flag_name    =  /*** can not exceed 16 bytes ***/,
                    txt_file_name=
                                        );

 %scan_flag_drug_abc(local_in_lib      = &perm_lib,
                     local_in_ds       = &in_ndc_ds,
                     local_out_lib     = &lwork,
                     local_out_ds      = &out_ds_prefix,
                     drug_main_cat_name= &flag_name   /*** can not exceed 16 bytes ***/,
                     drug_txt_file_you_made =&def_path.&txt_file_name ,
                     local_prod_id     = &prod_id ,
                     local_prod_ndc    = &prod_ndc
                     );

     data &lwork..&out_ds_prefix._&flag_name;
         set  &lwork..&out_ds_prefix._&flag_name;
             drop flag_:;
     run;

%mend;



/*** this will take all your prod scans and combine them into a single table of data ***/
/*** the prefix assigned will ensure all these tables are associated or gathered     ***/
/*** together correctly. ***/

%macro scan_overall_process(proj_prefix=);

     /*** clean up data from any previous attempt or run of code ***/
     /*** note for zt - might want to add in something to make
          the ds prefix more risk free ***/
     /*** note for zt - can we make the filename risk free from
          case sensitivity for - any operating system ***/
     proc datasets lib=&perm_lib  nolist;
             delete &proj_prefix._:;
             quit;
     run;


     /*** add as many text files for prod scans as you need ***/
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=azat     , txt_file_name= zt_text_sample_azat.txt   );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=inflix   , txt_file_name= zt_text_sample_inflix.txt );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=adalim   , txt_file_name= ADALIMUMAB.txt            );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=antibac  , txt_file_name= Antibacterial.txt         );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=certol   , txt_file_name= CERTOLIZUMAB.txt          );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=fiveasa  , txt_file_name= FiveASA.txt               );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=nataliz  , txt_file_name= NATALIZUMAB.txt           );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=sixmp    , txt_file_name= SixMP.txt                 );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=steriods , txt_file_name= Steroids.txt              );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=tofacit  , txt_file_name= tofacitinib.txt           );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=ustek    , txt_file_name= Ustekinumab.txt           );
     %scan_various(out_ds_prefix=&proj_prefix  , flag_name=vedoliz  , txt_file_name= Vedolizumab.txt           );

     /*** clean up data from any previous attempt or run of code ***/
     proc datasets lib=&perm_lib  nolist;
             delete  &out_ds_prod_nm ;
             quit;
     run;


     data &out_ds_prod_cats ;
         merge
         &lwork..&proj_prefix._:
         ;
         by &prod_id &prod_ndc ;
     run;

     proc freq data=&out_ds_prod_cats ;
     table &med_ndc_pfx.:;
     run;

%mend;

%scan_overall_process(proj_prefix=test );