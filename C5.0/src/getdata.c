/*************************************************************************/
/*                                                                       */
/*  Copyright 2010 Rulequest Research Pty Ltd.                           */
/*                                                                       */
/*  This file is part of Cubist GPL Edition, a single-threaded version   */
/*  of Cubist release 2.07.                                              */
/*                                                                       */
/*  Cubist GPL Edition is free software: you can redistribute it and/or  */
/*  modify it under the terms of the GNU General Public License as       */
/*  published by the Free Software Foundation, either version 3 of the   */
/*  License, or (at your option) any later version.                      */
/*                                                                       */
/*  Cubist GPL Edition is distributed in the hope that it will be        */
/*  useful, but WITHOUT ANY WARRANTY; without even the implied warranty  */
/*  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the     */
/*  GNU General Public License for more details.                         */
/*                                                                       */
/*  You should have received a copy of the GNU General Public License    */
/*  (gpl.txt) along with Cubist GPL Edition.  If not, see                */
/*                                                                       */
/*      <http://www.gnu.org/licenses/>.                                  */
/*                                                                       */
/*************************************************************************/

/*************************************************************************/
/*                                                                       */
/* Get cases from data file      */
/* ------------------------      */
/*                                                                       */
/*************************************************************************/

#include "defns.h"
#include "extern.h"

#include <stdint.h>

#include "redefine.h"
#include "transform.h"

#include <Rmath.h>

#define Inc 5120

/*  Alternative random number generator  */

#define AltRandom my_rand()
static double my_rand() {
  double dval;
  GetRNGstate();
  dval = runif(0, 1);
  PutRNGstate();
  return dval;
}

#define Inc 5120

Boolean SuppressErrorMessages = false;
#define XError(a, b, c)                                                        \
  if (MODE == m_build) {                                                       \
    if (!SuppressErrorMessages)                                                \
      Error((a), (b), (c));                                                    \
  } else {                                                                     \
    Error((a), (b), (c));                                                      \
  }

CaseNo SampleFrom; /* file count for sampling */

//int fileNumber = 0;

/*************************************************************************/
/*                                                                       */
/* Read raw cases from file with given extension.    */
/*                                                                       */
/* On completion, cases are stored in array Case in the form  */
/* of vectors of attribute values, and MaxCase is set to the  */
/* number of data cases.       */
/*                                                                       */
/*************************************************************************/

void GetData(FILE *Df, Boolean Train, Boolean AllowUnknownClass)
/*   -------  */
{
  DataRec DVec;
  int i = 0;
  CaseNo CaseSpace, WantTrain, LeftTrain, WantTest, LeftTest;
  Boolean FirstIgnore = true, SelectTrain;

  LineNo = 0;
  SuppressErrorMessages = SAMPLE && !Train;
  
  
  //Realloc(Case, 2000000 + 1, DataRec);
  
  Rprintf("\n GetData 1 ---\n");

  /*  Don't reset case count if appending data for xval  */

    if (Train || !Case) {
      MaxCase = MaxLabel = CaseSpace = 0;
      Case = Alloc(1, DataRec); /* for error reporting */
      //Realloc(Case, 1500001, DataRec);
      //printf("\n GetData 2 ---\n");
      //fileNumber = fileNumber + 1;
    } else {
      CaseSpace = MaxCase + 1;
      MaxCase++;
      //printf("\n GetData 3 ---\n");
    }

  //printf("\n GetData 4 ---\n");

  if (SAMPLE) {
    if (Train) {
      //printf("\n GetData 5 ---\n");
      SampleFrom = CountData(Df);
      ResetKR(KRInit); /* initialise KRandom() */
    } else {
      ResetKR(KRInit); /* restore  KRandom() */
      //printf("\n GetData 6 ---\n");
    }

    //printf("\n GetData 7 ---\n");

    WantTrain = SampleFrom * SAMPLE + 0.5;
    LeftTrain = SampleFrom;

    WantTest = (SAMPLE < 0.5 ? WantTrain : SampleFrom - WantTrain);
    LeftTest = SampleFrom - WantTrain;
    //printf("\n GetData 8 ---\n");
  }

  while ((DVec = GetDataRec(Df, Train))) {
    //printf("\n GetData 9 ---\n");
    /*  Check whether to include if we are sampling */

    if (SAMPLE) {
      SelectTrain = KRandom() < WantTrain / (float)LeftTrain--;
      //printf("\n GetData 10 ---\n");

      /*  Include if
    * Select and this is the training set
    * ! Select and this is the test set and sub-select
    NB: Must use different random number generator for
   sub-selection since cannot disturb random number sequence  */

      if (SelectTrain) {
        WantTrain--;
        //printf("\n GetData 11 ---\n");
      }

      if (SelectTrain != Train ||
          (!Train && AltRandom >= WantTest / (float)LeftTest--)) {
        FreeLastCase(DVec);
        //printf("\n GetData 12 ---\n");
        continue;
      }

      if (!Train) {
        WantTest--;
        //printf("\n GetData 13 ---\n");
      }
    }

    /*  Make sure there is room for another case  */

    if (MaxCase >= CaseSpace) {
      //printf("\n GetData 14 ---\n");
      CaseSpace += Inc;
      //Rprintf("\n GetData ALLOCATED --- %ld ---\n", CaseSpace);
      Realloc(Case, CaseSpace + 1, DataRec);
      //printf("\n GetData 15 ---\n");
    }

    /*  Ignore cases with unknown class  */

    if (AllowUnknownClass || (Class(DVec) & 077777777) > 0) {
      Case[MaxCase] = DVec;
      MaxCase++;
      //printf("GetData MAX CASE %ld ----\n ", MaxCase);
      //printf("\n GetData 16 ---\n");
      //i = i + 1;
      
      //Rprintf("GetData CASE %s ----\n ", Case[MaxCase]);
      //printf("GetData CASESPACE %ld ----\n ", CaseSpace);
      //Rprintf("GetData strlen Case %ld ----\n ", strlen(DVec));
    } else {
      if (FirstIgnore && Of) {
        fprintf(Of, T_IgnoreBadClass);
        FirstIgnore = false;
        //printf("\n GetData 17 ---\n");
      }
      //printf("\n GetData 18 ---\n");
      FreeLastCase(DVec);
      //printf("\n GetData 19 ---\n");
    }
  }
  Rprintf("\n GetData TERMINA ---\n");
  fclose(Df);
  
  MaxCase--;
}

/*************************************************************************/
/*                                                                       */
/* Read a raw case from file Df.      */
/*                                                                       */
/* For each attribute, read the attribute value from the file.  */
/* If it is a discrete valued attribute, find the associated no.  */
/* of this attribute value (if the value is unknown this is 0).  */
/*                                                                       */
/* Returns the DataRec of the case (i.e. the array of attribute  */
/* values).        */
/*                                                                       */
/*************************************************************************/

DataRec GetDataRec(FILE *Df, Boolean Train)
/*      ----------  */
{
  Attribute Att;
  char Name[1000000], *EndName;
  int Dv, Chars;
  DataRec DVec;
  ContValue Cv;
  Boolean FirstValue = true;
  int val;
  char* string = 0;
  
  //Rprintf("\n GetDataRec 1 ---\n");
  
  /*if(MaxCase >= 1562421){
    string = (char*)calloc(4000+1, sizeof(char));  
    fgets(string, 4000, Df);
    
    Rprintf("\n GetFile .data STRLEN %ld ---\n", strlen(string));
    Rprintf("\n GetFile .data --- %s ---\n", string);
  }*/

  val = ReadName(Df, Name, 10000000, '\00'); 
  //Rprintf("\n GetDataRec STRLEN Name %ld ---\n", strlen(Name));
  //Rprintf("\n GetDataRec Name %s --\n", Name); 

  if (val) {
    //Rprintf("\n GetDataRec 2 ---\n");
    Case[MaxCase] = DVec = NewCase();
    ForEach(Att, 1, MaxAtt) {
      if (AttDef[Att]) {
        DVec[Att] = EvaluateDef(AttDef[Att], DVec);
        //Rprintf("\n GetDataRec 3 ---\n");
        if (Continuous(Att)) {
          CheckValue(DVec, Att);
          //Rprintf("\n GetDataRec 4 ---\n");
        }

        if (SomeMiss) {
          SomeMiss[Att] |= Unknown(DVec, Att);
          SomeNA[Att] |= NotApplic(DVec, Att);
          //Rprintf("\n GetDataRec 5 ---\n");
        }

        continue;
      }

      /*  Get the attribute value if don't already have it  */

      if (!FirstValue && !ReadName(Df, Name, 1000000, '\00')) {
        XError(HITEOF, AttName[Att], "");
        FreeLastCase(DVec);
        //Rprintf("\n GetDataRec 6 ---\n");
        return Nil;
      }
      FirstValue = false;

      if (Exclude(Att)) {
        if (Att == LabelAtt) {
          /*  Record the value as a string  */
          //Rprintf("\n GetDataRec 7 ---\n");
          SVal(DVec, Att) = StoreIVal(Name);
        }
      } else if (!strcmp(Name, "?")) {
        /*  Set marker to indicate missing value  */
        //Rprintf("\n GetDataRec 8 ---\n");
        DVal(DVec, Att) = UNKNOWN;
        if (SomeMiss)
          SomeMiss[Att] = true;
      } else if (Att != ClassAtt && !strcmp(Name, "N/A")) {
        /*  Set marker to indicate not applicable  */
        //Rprintf("\n GetDataRec 9 ---\n");
        DVal(DVec, Att) = NA;
        if (SomeNA)
          SomeNA[Att] = true;
          //Rprintf("\n GetDataRec 10 ---\n");
      } else if (Discrete(Att)) {
        /*  Discrete attribute  */
        //Rprintf("\n GetDataRec 11 ---\n");
        Dv = Which(Name, AttValName[Att], 1, MaxAttVal[Att]);
        if (!Dv) {
          if (StatBit(Att, DISCRETE)) {
            if (Train || XVAL) {
              /*  Add value to list  */
              //Rprintf("\n GetDataRec 12 ---\n");
              if (MaxAttVal[Att] >= (long)(intptr_t)AttValName[Att][0]) {
                XError(TOOMANYVALS, AttName[Att],
                       (char *)AttValName[Att][0] - 1);
                Dv = MaxAttVal[Att];
                //Rprintf("\n GetDataRec 13 ---\n");
              } else {
                Dv = ++MaxAttVal[Att];
                AttValName[Att][Dv] = strdup(Name);
                AttValName[Att][Dv + 1] = "<other>"; /* no free */
                //Rprintf("\n GetDataRec 14 ---\n");
              }
              if (Dv > MaxDiscrVal) {
                MaxDiscrVal = Dv;
                //Rprintf("\n GetDataRec 15 ---\n");
              }
            } else {
              /*  Set value to "<other>"  */
              //Rprintf("\n GetDataRec 16 ---\n");
              Dv = MaxAttVal[Att] + 1;
            }
          } else {
            XError(BADATTVAL, AttName[Att], Name);
            Dv = UNKNOWN;
            //Rprintf("\n GetDataRec 17 ---\n");
          }
        }
        DVal(DVec, Att) = Dv;
        //Rprintf("\n GetDataRec 18 ---\n");
      } else {
        /*  Continuous value  */

        if (TStampVal(Att)) {
          CVal(DVec, Att) = Cv = TStampToMins(Name);
          //Rprintf("\n GetDataRec 19 ---\n");
          if (Cv >= 1E9) /* long time in future */
          {
            XError(BADTSTMP, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
            //Rprintf("\n GetDataRec 20 ---\n");
          }
        } else if (DateVal(Att)) {
          CVal(DVec, Att) = Cv = DateToDay(Name);
          if (Cv < 1) {
            XError(BADDATE, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
            //Rprintf("\n GetDataRec 21 ---\n");
          }
        } else if (TimeVal(Att)) {
          CVal(DVec, Att) = Cv = TimeToSecs(Name);
          if (Cv < 0) {
            XError(BADTIME, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
            //Rprintf("\n GetDataRec 22 ---\n");
          }
        } else {
          CVal(DVec, Att) = strtod(Name, &EndName);
          if (EndName == Name || *EndName != '\0') {
            XError(BADATTVAL, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
            //Rprintf("\n GetDataRec 23 ---\n");
          }
        }
        //Rprintf("\n GetDataRec 24 ---\n");
        CheckValue(DVec, Att);
      }
    }

    if (ClassAtt) {
      if (Discrete(ClassAtt)) {
        //Rprintf("\n GetDataRec 25 ---\n");
        Class(DVec) = XDVal(DVec, ClassAtt);
      } else if (Unknown(DVec, ClassAtt) || NotApplic(DVec, ClassAtt)) {
        Class(DVec) = 0;
        //Rprintf("\n GetDataRec 26 ---\n");
      } else {
        /*  Find appropriate segment using class thresholds  */
        //Rprintf("\n GetDataRec 27 ---\n");
        Cv = CVal(DVec, ClassAtt);

        for (Dv = 1; Dv < MaxClass && Cv > ClassThresh[Dv]; Dv++)
          ;

        Class(DVec) = Dv;
      }
    } else {
      if (!ReadName(Df, Name, 1000000, '\00')) {
        XError(HITEOF, Fn, "");
        FreeLastCase(DVec);
        //Rprintf("\n GetDataRec 28 ---\n");
        return Nil;
      }

      if ((Class(DVec) = Dv = Which(Name, ClassName, 1, MaxClass)) == 0) {
        if (strcmp(Name, "?")) {
          XError(BADCLASS, "", Name);
          //Rprintf("\n GetDataRec 29 ---\n");
        }
      }
    }

    if (LabelAtt &&
        (Chars = strlen(IgnoredVals + SVal(DVec, LabelAtt))) > MaxLabel) {
      MaxLabel = Chars;
      //Rprintf("\n GetDataRec 30 ---\n");
    }
    //Rprintf("\n GetDataRec strlen string %ld---\n", strlen(Name));
    //Rprintf("\n termina GetDataRec ---\n");
    return DVec;
  } else {
    //Rprintf("\n GetDataRec 31 NIL ---\n");
    return Nil;
  }
}

DataRec PredictGetDataRec(FILE *Df, Boolean Train)
/*      ----------  */
{
  Attribute Att;
  char Name[1000], *EndName;
  int Dv;
  DataRec Dummy, DVec;
  ContValue Cv;
  Boolean FirstValue = true;

  if (ReadName(Df, Name, 1000, '\00')) {
    Dummy = AllocZero(MaxAtt + 2, AttValue);
    DVec = &Dummy[1];
    ForEach(Att, 1, MaxAtt) {
      if (AttDef[Att]) {
        DVec[Att] = EvaluateDef(AttDef[Att], DVec);

        if (Continuous(Att)) {
          CheckValue(DVec, Att);
        }

        if (SomeMiss) {
          SomeMiss[Att] |= Unknown(DVec, Att);
          SomeNA[Att] |= NotApplic(DVec, Att);
        }

        continue;
      }

      /*  Get the attribute value if don't already have it  */

      if (!FirstValue && !ReadName(Df, Name, 1000, '\00')) {
        XError(HITEOF, AttName[Att], "");
        PredictFreeLastCase(DVec);
        return Nil;
      }
      FirstValue = false;

      if (Exclude(Att)) {
        if (Att == LabelAtt) {
          /*  Record the value as a string  */

          SVal(DVec, Att) = StoreIVal(Name);
        }
      } else if (!strcmp(Name, "?")) {
        /*  Set marker to indicate missing value  */

        DVal(DVec, Att) = UNKNOWN;
        if (SomeMiss)
          SomeMiss[Att] = true;
      } else if (Att != ClassAtt && !strcmp(Name, "N/A")) {
        /*  Set marker to indicate not applicable  */

        DVal(DVec, Att) = NA;
        if (SomeNA)
          SomeNA[Att] = true;
      } else if (Discrete(Att)) {
        /*  Discrete attribute  */

        Dv = Which(Name, AttValName[Att], 1, MaxAttVal[Att]);
        if (!Dv) {
          if (StatBit(Att, DISCRETE)) {
            if (Train) {
              /*  Add value to list  */

              if (MaxAttVal[Att] >= (long)(intptr_t)AttValName[Att][0]) {
                XError(TOOMANYVALS, AttName[Att],
                       (char *)AttValName[Att][0] - 1);
                Dv = MaxAttVal[Att];
              } else {
                Dv = ++MaxAttVal[Att];
                AttValName[Att][Dv] = strdup(Name);
                AttValName[Att][Dv + 1] = "<other>"; /* no free */
              }
            } else {
              /*  Set value to "<other>"  */

              Dv = MaxAttVal[Att] + 1;
            }
          } else {
            XError(BADATTVAL, AttName[Att], Name);
            Dv = UNKNOWN;
          }
        }
        DVal(DVec, Att) = Dv;
      } else {
        /*  Continuous value  */

        if (TStampVal(Att)) {
          CVal(DVec, Att) = Cv = TStampToMins(Name);
          if (Cv >= 1E9) /* long time in future */
          {
            XError(BADTSTMP, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
          }
        } else if (DateVal(Att)) {
          CVal(DVec, Att) = Cv = DateToDay(Name);
          if (Cv < 1) {
            XError(BADDATE, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
          }
        } else if (TimeVal(Att)) {
          CVal(DVec, Att) = Cv = TimeToSecs(Name);
          if (Cv < 0) {
            XError(BADTIME, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
          }
        } else {
          CVal(DVec, Att) = strtod(Name, &EndName);
          if (EndName == Name || *EndName != '\0') {
            XError(BADATTVAL, AttName[Att], Name);
            DVal(DVec, Att) = UNKNOWN;
          }
        }

        CheckValue(DVec, Att);
      }
    }

    if (ClassAtt) {
      if (Discrete(ClassAtt)) {
        Class(DVec) = XDVal(DVec, ClassAtt);
      } else if (Unknown(DVec, ClassAtt) || NotApplic(DVec, ClassAtt)) {
        Class(DVec) = 0;
      } else {
        /*  Find appropriate segment using class thresholds  */

        Cv = CVal(DVec, ClassAtt);

        for (Dv = 1; Dv < MaxClass && Cv > ClassThresh[Dv]; Dv++)
          ;

        Class(DVec) = Dv;
      }
    } else {
      if (!ReadName(Df, Name, 1000, '\00')) {
        XError(HITEOF, Fn, "");
        PredictFreeLastCase(DVec);
        return Nil;
      }

      Class(DVec) = Dv = Which(Name, ClassName, 1, MaxClass);
    }

    return DVec;
  } else {
    return Nil;
  }
}

/*************************************************************************/
/*                                                                       */
/*      Count cases in data file      */
/*                                                                       */
/*************************************************************************/

CaseNo CountData(FILE *Df)
/*     ---------  */
{
  char Last = ',';
  int Count = 0, Next;

  while (true) {
    if ((Next = getc(Df)) == EOF) {
      if (Last != ',')
        Count++;
      rewind(Df);
      return Count;
    }

    if (Next == '|') {
      while ((Next = getc(Df)) != '\n')
        ;
    }

    if (Next == '\n') {
      if (Last != ',')
        Count++;
      Last = ',';
    } else if (Next == '\\') {
      /*  Skip escaped character  */

      getc(Df);
    } else if (Next != '\t' && Next != ' ') {
      Last = Next;
    }
  }
}

/*************************************************************************/
/*                                                                       */
/* Store a label or ignored value in IValStore    */
/*                                                                       */
/*************************************************************************/

int StoreIVal(String S)
/*  ---------  */
{
  int StartIx, Length;

  if ((Length = strlen(S) + 1) + IValsOffset > IValsSize) {
    if (IgnoredVals) {
      Realloc(IgnoredVals, IValsSize += 32768, char);
    } else {
      IValsSize = 32768;
      IValsOffset = 0;
      IgnoredVals = Alloc(IValsSize, char);
    }
  }

  StartIx = IValsOffset;
  strcpy(IgnoredVals + StartIx, S);
  IValsOffset += Length;

  return StartIx;
}

/*************************************************************************/
/*                                                                       */
/* Free case space        */
/*                                                                       */
/*************************************************************************/

void FreeData()
/*   --------  */
{
  FreeCases();

  FreeUnlessNil(IgnoredVals);
  IgnoredVals = Nil;
  IValsSize = 0;

  Free(Case);
  Case = Nil;

  MaxCase = -1;
}

/*************************************************************************/
/*                                                                       */
/* Check for bad continuous value      */
/*                                                                       */
/*************************************************************************/

void CheckValue(DataRec DVec, Attribute Att)
/*   ----------  */
{
  ContValue Cv;

  Cv = CVal(DVec, Att);
  if (!isfinite(Cv)) {
    Error(BADNUMBER, AttName[Att], "");
    
    CVal(DVec, Att) = UNKNOWN;
  }
}