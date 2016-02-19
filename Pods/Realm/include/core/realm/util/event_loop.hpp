/*************************************************************************
 *
 * REALM CONFIDENTIAL
 * __________________
 *
 *  [2011] - [2015] Realm Inc
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Realm Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Realm Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Realm Incorporated.
 *
 **************************************************************************/

#ifndef REALM_UTIL_EVENT_LOOP_HPP
#define REALM_UTIL_EVENT_LOOP_HPP

#include <realm/util/network.hpp>

namespace realm {
namespace util {

class SocketBase;
class DeadlineTimerBase;
class ResolverBase;

class EventLoopBase {
public:
    virtual ~EventLoopBase() {}

    using Duration = std::chrono::milliseconds;

    using OnConnectComplete = std::function<void(std::error_code)>;
    using OnTimeout = std::function<void(std::error_code)>;

    virtual std::unique_ptr<SocketBase> async_connect(std::string host, int port, OnConnectComplete) = 0;
    virtual std::unique_ptr<DeadlineTimerBase> async_timer(Duration delay, OnTimeout) = 0;
};

class ResolverBase {
public:
    virtual ~ResolverBase() {}

    virtual void cancel() = 0;
};

class SocketBase {
public:
    virtual ~SocketBase() {}

    using OnWriteComplete = std::function<void(std::error_code, size_t num_bytes_transferred)>;
    using OnReadComplete = std::function<void(std::error_code, size_t num_bytes_transferred)>;

    virtual void close() = 0;
    virtual void cancel() = 0;

    virtual void async_write(const char* data, size_t size, OnWriteComplete) = 0;
    virtual void async_read(char* buffer, size_t size, OnReadComplete) = 0;
    virtual void async_read_until(char* buffer, size_t size, char delim, OnReadComplete) = 0;
};

class DeadlineTimerBase {
public:
    virtual ~DeadlineTimerBase() {}

    using OnComplete = std::function<void(std::error_code)>;
    using Duration = EventLoopBase::Duration;

    virtual void cancel() = 0;

    virtual void async_wait(Duration delay, OnComplete) = 0;
};

template<class EventLoopProvider> class EventLoop;

using ASIO = network::io_service;

template<>
class EventLoop<ASIO>: public EventLoopBase {
public:
    EventLoop();
    ~EventLoop();

    void run();
    void stop() noexcept;
    void reset() noexcept;

    std::unique_ptr<SocketBase> async_connect(std::string host, int port, OnConnectComplete) final;
    std::unique_ptr<DeadlineTimerBase> async_timer(Duration delay, OnTimeout) final;
protected:
    struct Resolver;
    struct Socket;
    struct DeadlineTimer;

    ASIO m_io_service;
};

} // namespace util
} // namespace realm


#endif // REALM_UTIL_EVENT_LOOP_HPP

