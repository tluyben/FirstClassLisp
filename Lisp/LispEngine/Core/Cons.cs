﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LispEngine.Datums;
using LispEngine.Evaluation;

namespace LispEngine.Core
{
    class Cons : DatumHelpers, Function
    {
        public static readonly Cons Instance = new Cons();
        public Datum Evaluate(Evaluator evaluator, Datum args)
        {
            var argDatums = enumerate(args).ToArray();
            if(argDatums.Length != 2)
                throw new Exception(string.Format("Exactly 2 arguments expected to 'cons'"));
            return cons(argDatums[0], argDatums[1]);
        }
    }
}