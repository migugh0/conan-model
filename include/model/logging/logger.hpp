// Copyright (c) 2016-2023 Knuth Project developers.
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
// SPDX-License-Identifier: MIT

#pragma once

#include <spdlog/spdlog.h>

class logger {
    std::string const name_;

public:
    logger(std::string name);

    template <typename FormatString, typename... Args>
    inline
    void trace(FormatString const& fmt, Args const&... args) const {
        spdlog::get(name_)->trace(fmt, args...);
    }

    template <typename FormatString, typename... Args>
    inline
    void info(FormatString const& fmt, Args const&... args) const {
        spdlog::get(name_)->info(fmt, args...);
    }

    template <typename FormatString, typename... Args>
    inline
    void warn(FormatString const& fmt, Args const&... args) const {
        spdlog::get(name_)->warn(fmt, args...);
    }

    template <typename FormatString, typename... Args>
    inline
    void error(FormatString const& fmt, Args const&... args) const {
        spdlog::get(name_)->error(fmt, args...);
    }
};
