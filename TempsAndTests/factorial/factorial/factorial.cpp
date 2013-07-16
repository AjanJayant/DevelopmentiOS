//
//  factorial.cpp
//  factorial
//
//  Created by Ajan Jayant on 2013-04-15.
//  Copyright (c) 2013 Ajan Jayant. All rights reserved.
//
#include <iostream>
#include "factorial.h"
#include "hello.h"

int factorial(int x)
{
    hello();
    std::cout << std::endl;
    int ans = 1;
    while(x > 0)
    {
        ans = ans * x;
        x--;
    }
    return ans;
}