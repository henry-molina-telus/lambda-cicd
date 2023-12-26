exports.handler = async (event, context) => {
    var response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "isBase64Encoded": false,
        "body": {
            message: "Hello World!!!"
        }
    }

    return response;
};