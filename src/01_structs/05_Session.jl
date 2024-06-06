"""
	Session

This is a web session.

```jldoctest
julia> capabilities = Capabilities("chrome")
Remote WebDriver Capabilities
browserName: chrome
julia> wd = RemoteWebDriver(capabilities, host = ENV["WEBDRIVER_HOST"], port = parse(Int, ENV["WEBDRIVER_PORT"]))
Remote WebDriver
julia> session = Session(wd)
Session
julia> isa(session, Session)
true
julia> delete!(session);

```
"""
struct Session{D<:Object}
    addr::String
    id::String
    attrs::D
    function Session(wd::RemoteWebDriver, headless=false)
        @unpack addr = wd
        d = Dict("browserName" => wd.capabilities.browserName, "timeouts" => wd.capabilities.timeouts, "unhandledPromptBehavior" => wd.capabilities.unhandledPromptBehavior)
        d["goog:chromeOptions"] = Dict("args" => ["--window-size=1920,1080", "--start-maximized"], "prefs" => Dict("profile.default_content_setting_values.automatic_downloads" => 1,))
        if headless
            d["goog:chromeOptions"] = Dict("args" => ["--headless", "--window-size=1920,1080", "--start-maximized"])
        end
        response = HTTP.post(
            "$(wd.addr)/session",
            [("Content-Type" => "application/json")],
            JSON3.write(Dict("desiredCapabilities" => d)),
        )
        @assert response.status == 200
        json = JSON3.read(response.body)
        new{typeof(json.value)}(addr, json.sessionId, json.value)
    end
end
broadcastable(obj::Session) = Ref(obj)
summary(io::IO, obj::Session) = println(io, "Session")
function show(io::IO, obj::Session)
    print(io, summary(obj))
end
