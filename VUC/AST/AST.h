/*******************************************************************

        PROPRIETARY NOTICE

These coded instructions, statements, and computer programs contain
proprietary information of the Visual Urlang project, and are protected
under copyright law. They may not be distributed, copied, or used except
under the provisions of the terms of the End-User License Agreement, in
the file "EULA.md", which should have been included with this file.

        Copyright Notice

    (c) 2019-2020 The Visual Urlang Project.
              All rights reserved.
********************************************************************/

#pragma once

#include <string>

#define UNIMPL                                                                 \
    std::cout << "FAULT: " << __FUNCSIG__ << ": Not implemented in "           \
              << typeid(*this).name() << "\n"

inline std::string blanks(size_t n) { return std::string(n, ' '); }
