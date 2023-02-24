// Copyright (c) 2016-2023 Knuth Project developers.
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.
// SPDX-License-Identifier: MIT

#pragma once

#include <model/logging/logger.hpp>

struct server_logger : logger {
    server_logger() : logger{"app_server"} {}

    template <typename Message_Builder>
    void trace(Message_Builder&& msg_builder) const {
        logger::trace(msg_builder());
    }

    template <typename Message_Builder>
    void info(Message_Builder&& msg_builder) const {
        logger::info(msg_builder());
    }

    template <typename Message_Builder>
    void warn(Message_Builder&& msg_builder) const {
        logger::warn(msg_builder());
    }

    template <typename Message_Builder>
    void error(Message_Builder&& msg_builder) const {
        logger::error(msg_builder());
    }
};
