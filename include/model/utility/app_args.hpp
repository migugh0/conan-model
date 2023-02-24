// Copyright (c) 2016-2023 Knuth Project developers.
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
// SPDX-License-Identifier: MIT

#include <cstdint>
#include <optional>

#include <nonstd/expected.hpp>

#include <string>

struct app_args_t {
    std::uint64_t int_a{100};
    std::uint64_t int_b{200};
    std::optional<std::string> welcome_message;

    enum class result { help, error };
    static nonstd::expected<app_args_t, result> parse(int argc, const char *argv[]);
};
