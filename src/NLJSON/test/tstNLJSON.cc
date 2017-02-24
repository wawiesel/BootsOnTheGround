#include <gtest/gtest.h>
#include <nlohmann/json.hpp>

// Example taken from:
// http://nlohmann.github.io/json/ examples
// which linked to http://melpon.org/wandbox/permlink/VzSqLszbnoWE92dD

using namespace nlohmann;

// a JSON text
auto test_text1 = R"(
    {
        "Image": {
            "Width":  800,
            "Height": 600,
            "Title":  "View from 15th Floor",
            "Thumbnail": {
                "Url":    "http://www.example.com/image/481989943",
                "Height": 125,
                "Width":  100
            },
            "Animated" : false,
            "IDs": [116, 943, 234, 38793]
        }
    }
)";

TEST( NLJson, CompleteParse )
{
    // fill a stream with JSON text
    std::stringstream ss;
    ss << "\n" << test_text1;

    // create JSON from stream (setw controls indent!)
    json j_complete = json::parse( ss );

    auto ref_output = R"(
{
    "Image": {
        "Animated": false,
        "Height": 600,
        "IDs": [
            116,
            943,
            234,
            38793
        ],
        "Thumbnail": {
            "Height": 125,
            "Url": "http://www.example.com/image/481989943",
            "Width": 100
        },
        "Title": "View from 15th Floor",
        "Width": 800
    }
})";
    std::stringstream test_output;
    test_output << "\n" << std::setw( 4 ) << j_complete;
    EXPECT_EQ( ref_output, test_output.str() ) << "ref:\n"
                                               << ref_output << "\n\ntest:\n"
                                               << test_output.str() << "\n";
}

TEST( NLJson, FilteredParse )
{
    // define parser callback
    json::parser_callback_t cb = [](
        int depth, json::parse_event_t event, json& parsed ) {
        // skip object elements with key "Thumbnail"
        if( event == json::parse_event_t::key and
            parsed == json( "Thumbnail" ) )
        {
            return false;
        }
        else
        {
            return true;
        }
    };

    // fill a stream with JSON text
    std::stringstream ss;
    ss << "\n" << test_text1;

    // create JSON from stream (with callback)
    json j_filtered = json::parse( ss, cb );
    auto ref_output = R"(
{
    "Image": {
        "Animated": false,
        "Height": 600,
        "IDs": [
            116,
            943,
            234,
            38793
        ],
        "Title": "View from 15th Floor",
        "Width": 800
    }
})";
    std::stringstream test_output;
    test_output << "\n" << std::setw( 4 ) << j_filtered;
    EXPECT_EQ( ref_output, test_output.str() ) << "ref:\n"
                                               << ref_output << "\n\ntest:\n"
                                               << test_output.str() << "\n";
}
