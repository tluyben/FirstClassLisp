﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LispEngine.Datums;
using LispEngine.Evaluation;
using Environment = LispEngine.Evaluation.Environment;

namespace LispEngine.Core
{
    class Begin : AbstractFExpression
    {
        public static readonly FExpression Instance = new Begin();

        private static Continuation popResult(Continuation c)
        {
            return c.PopResult();
        }

        public override Continuation Evaluate(Continuation c, Environment env, Datum args)
        {
            var argList = args.ToArray();
            if (argList.Length < 1)
                throw c.error("Expected at least 1 expression for begin. Got none.");
            // Scope any local definitions.
            var localEnv = new Environment(env);
            var remaining = argList.Reverse().ToArray();
            for (var i = 0; i < remaining.Length; ++i)
            {
                if (i > 0)
                    c = c.PushTask(popResult, "ignore");
                c = c.Evaluate(localEnv, remaining[i]);
            }
            return c;
        }

        public override string ToString()
        {
            return ",begin";
        }
    }
}
