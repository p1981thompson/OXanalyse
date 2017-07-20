
packages <- c("ggplot2", "dplyr","devtools", "rmarkdown","RCurl","papaja","bibtex","foreign","xlsx","psych","osfr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages()))) 
}

devtools::install_github("crsh/papaja")
devtools::install_github("p1981thompson/osfr")


############################################################################
Project.setup<-function(){
  
  ########FUNCTIONS#################
  
  data.FUN<-function()
  {
    data.locate<-choose.files(getwd(),"choose location of data")
    file.copy(data.locate,data.path)
    data.locate2<-paste0(data.path,"/",basename(data.locate))
    #
    if(basename(data.locate2)=="csv"){data=read.csv(data.locate2)}
    if(basename(data.locate2)=="dta"){data=foreign::read.dta(data.locate2)}
    if(basename(data.locate2)=="spss"){data=foreign::read.spss(data.locate2)}
    if(basename(data.locate2)=="spss"){data=foreign::read.spss(data.locate2)}
    if(basename(data.locate2)=="xlsx"){data=foreign::read.xlsx(data.locate2)}
    
  }
  
  data.gen<-function()
  {
    data <- data.frame(ID=integer(),
                       Dependent_var=numeric(),
                       categorical_predictor=factor(),
                       continuous_predictor=numeric())
    write.csv(data,paste0(data.path,"/data_template.csv"))
    message("A sample data template has been generated for you") 
  }
  
  writeUp.gen<-function()
  {
   
    library(papaja)
    library(rmarkdown)
    library(RCurl)
    
    rmarkdown::draft(
      paste0(writeUp.path,"/",A2,".Rmd")
      , "apa6"
      , package = "papaja"
      , create_dir = FALSE
      , edit = FALSE
    )
    
    tx<-readLines(paste0(writeUp.path,"/",A2,".Rmd"))
    tx2<-gsub("pdf", "word",x=tx)
    tx2<-gsub("Ernst-August Doelle","Dorothy V. M. Bishop",x=tx2)
    tx2<-gsub("First Author",C,x=tx2)
    tx2<-gsub("my@email.com",D,x=tx2)
    tx2<-gsub("Postal address","Department of Experimental Psychology, Ewert Place, Banbury road, Summertown, Oxford, OX2 7DD",x=tx2)
    tx2<-gsub("Wilhelm-Wundt-University","Oxford University",x=tx2)
    tx2<-gsub("Konstanz Business School","Other University",x=tx2)
    tx2<-gsub("r-references.bib","mybibfile.bib",x=tx2)
    
    writeLines(tx2,con=paste0(writeUp.path,"/",A2,".Rmd"))
    
    writeLines(RCurl::getURL("https://raw.githubusercontent.com/p1981thompson/OXanalyse/master/mybibfile.bib"),paste0(writeUp.path,"/mybibfile.bib"))
    
  
  rmarkdown::render(paste0(writeUp.path,"/",A2,".Rmd"),output_format = "papaja:::apa6_word",output_file=paste0(writeUp.path,"/",A2,".docx"))
  }
  
  osf.link<-function()
  {
    
    library(devtools)
    library(osfr)
    browseURL("https://osf.io/settings/tokens/")
    Sys.sleep(time=60)
    print("You need to login to your account and request an API token.\n This permits the link between R and OSF. COPY THE TOKEN AND PASTE INTO R WHEN ASKED.")
    login()
    welcome()
    
    main<-create_project(title=A2,description=A3)
    
  }
  
  osf.link.gen<-function()
  {
    print("Register for an OSF account following the link which should pop up.")
    browseURL("https://osf.io/register/")
    
    Sys.sleep(time=60)
    library(devtools)
    library(osfr)
    browseURL("https://osf.io/settings/tokens/")
    print("You need to login to your new account and request an API token.\n This permits the link between R and OSF. COPY THE TOKEN AND PASTE INTO R WHEN ASKED.")
    login()
    welcome()
    
    main<-create_project(title=A2,description=A3)
    paper <- upload_file(id=main,filename=paste0(writeUp.path,"/",A2,".docx"))
    
  }
  
  #######################################
  
  A <- menu(c("Yes", "No"), title="Do you want to create a file directory for your project?")
  main.path <- ifelse(A==1,paste0(getwd(),"/Project_files"),choose.dir(getwd(), "Choose your project folder"))
  data.path <- if(A==1){paste0(getwd(),"/Project_files/Data")}
  analysis.path <- if(A==1){paste0(getwd(),"/Project_files/Analysis")}
  plots.path <- if(A==1){paste0(getwd(),"/Project_files/Plots")}
  writeUp.path <- if(A==1){paste0(getwd(),"/Project_files/writeUp")}
  
  A2<-readline("Enter the name of the Project: ")
  A3<-readline("Enter a brief description of the project (one sentence): ")
  
  main.folder<-ifelse(dir.exists(main.path)==FALSE,dir.create(main.path),stop("Folder already exists!"))
  data.folder<-ifelse(dir.exists(data.path)==FALSE,dir.create(data.path),stop("Folder already exists!"))
  analysis.folder<-ifelse(dir.exists(analysis.path)==FALSE,dir.create(analysis.path),stop("Folder already exists!"))
  plots.folder<-ifelse(dir.exists(plots.path)==FALSE,dir.create(plots.path),stop("Folder already exists!"))
  writeUp.folder<-ifelse(dir.exists(writeUp.path)==FALSE,dir.create(writeUp.path),stop("Folder already exists!"))
  
  
  B <- menu(c("Yes","No"),title="Do you have the data?")
  if(B==1){data.FUN()}
  else{data.gen()}
  
  
  C <- readline("Enter the first author's name: ")
  D <- readline("Enter the first author's email address: ")
  F <- menu(c("yes","no"),title="Do you want to link this project to OSF?")
  
  if(F==1){
  switch(menu(c("yes","no"),title="Do you have an OSF account?"),osf.link(),osf.link.gen())
  }
  
  writeUp.gen()
  
}
  