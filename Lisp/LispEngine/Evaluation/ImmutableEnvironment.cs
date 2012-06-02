﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using LispEngine.Datums;

namespace LispEngine.Evaluation
{
    public interface ImmutableEnvironment
    {
        Datum Lookup(string name);
    }
}