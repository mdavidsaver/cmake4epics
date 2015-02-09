
#include <subRecord.h>
#include <registryFunction.h>
#include <epicsExport.h>

static long myCounter(subRecord *prec)
{
    prec->val++;
    return 0;
}

epicsRegisterFunction(myCounter);
