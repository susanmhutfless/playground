/********************************************************************
* Job Name: 0_setup_facts.sas
* Job Desc: code that configures important settings
* COPYRIGHT (c) 2019 2020 Johns Hopkins University - HutflessLab 2019
********************************************************************
* Longer Desc:
*              the facts set and configured here enable subsequent
*              code that follows to correctly trigger, set according
*              to the required specifications of where this code
*              is run.
*       Alert: this job must be run before any other job in a clean
*              sas session
********************************************************************/

/*** start of section - global vars ***/
%global lwork ltemp shlib                    ;

/*** libname prefix alias assignments ***/
%let  lwork    = work                             ;
%let  ltemp    = temp                             ;
%let  shlib    = shu172sl                         ;

%global vpath proj_path code_path vrdc_code       ;
%let vpath     = /sas/vrdc/users/shu172/files     ;
%let proj_path = /jhu_projects/cd_cohort          ;
%let code_path = /code/                           ;
%let vrdc_code = &vpath./jhu_vrdc_code            ;

/*** start of section - local vars remote work ***/
%include "&vrdc_code./remote_dev_work_local.sas";
/*** end of section   - local vars remote work ***/

/*** make sure to run macros in ***/
%include "&vrdc_code./macro_tool_box.sas";
