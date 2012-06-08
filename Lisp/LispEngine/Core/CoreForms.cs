﻿using LispEngine.Evaluation;
using Environment = LispEngine.Evaluation.Environment;

namespace LispEngine.Core
{
    // Because we have implemented macros as first class objects,
    // *all* core forms can be simply be defined in the environment!
    public class CoreForms
    {
        public static Environment AddTo(Environment env)
        {
            env = env
                .Extend("lambda", Lambda.Instance)
                .Extend("cons", Cons.Instance)
                .Extend("apply", Apply.Instance)
                .Extend("eq?", Eq.Instance)
                .Extend("if", If.Instance)
                .Extend("macro", Macro.Instance)
                .Extend("quote", Quote.Instance)
                .Extend("define", Define.Instance)
                .Extend("call/cc", CallCC.Instance);
            return env;
        }
    }
}
