/********************************************************************
* Job Name: macro_ndc_char_scan_for_drug_name.sas
* Job Desc: code to scan for key char drug name or text and create
*           a flag or set of flag
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************/

%macro scan_flag_drug_abc(local_in_lib      = ,
                          local_in_ds       = ,
                          local_out_lib     = ,
                          local_out_ds      = ,
                          drug_main_cat_name=    /*** can not exceed 16 bytes ***/,
                          drug_txt_file_you_made= ,
                          local_prod_id     = ,
                          local_prod_ndc    =
                          );

data _null_;
    xlen=length("&drug_main_cat_name");
    ds_name="&local_out_ds" !!"_"!! "&drug_main_cat_name";
    call symputx('local_out_ds_drug_cat',ds_name);
run;

/*** clean up data from any previous attempt or run of code ***/
proc datasets lib= &local_out_lib nolist;
        delete &local_out_ds_drug_cat;
        quit;
run;

data &local_out_lib..&local_out_ds_drug_cat ;
    set &local_in_lib..&local_in_ds ;
    &med_ndc_pfx.&drug_main_cat_name = 0;

        %include "&drug_txt_file_you_made";

    drop pattern_:;
    &med_ndc_pfx.&drug_main_cat_name = sum(of flag_ndc_:);
    if &med_ndc_pfx.&drug_main_cat_name = 0 then delete;
    drop var_to_scan;
run;

proc freq data= &local_out_lib..&local_out_ds_drug_cat  ;
    title "scan for &drug_main_cat_name";
    table &med_ndc_pfx.&drug_main_cat_name;
    table flag_ndc_:;
run;
    title;

proc sort data= &local_out_lib..&local_out_ds_drug_cat   nodupkey ;
    by &local_prod_id  &local_prod_ndc ;
run;

%mend;
