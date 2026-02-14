import json
import os

import azure.functions as func
from azure.cosmos import CosmosClient

from src.visitors_service import increment_counter

app = func.FunctionApp()


def _get_container():
    endpoint = os.environ["COSMOS_ENDPOINT"]
    key = os.environ["COSMOS_KEY"]
    db_name = os.environ.get("COSMOS_DATABASE", "VisitorsCount")
    container_name = os.environ.get("COSMOS_CONTAINER", "counter")

    client = CosmosClient(endpoint, credential=key)
    db = client.get_database_client(db_name)
    return db.get_container_client(container_name)


@app.route(route="visitors", methods=["GET"], auth_level=func.AuthLevel.ANONYMOUS)
def visitors(req: func.HttpRequest) -> func.HttpResponse:
    """
    HTTP entry point.

    Responsibilities:
    - Obtain Cosmos container
    - Call service layer
    - Handle generic errors
    """

    container = _get_container()

    try:
        # call into the testable service layer
        count = increment_counter(container)

        return func.HttpResponse(
            body=json.dumps({"count": count}),
            status_code=200,
            mimetype="application/json",
        )

    except Exception as e:
        # Preserves global error handling behavior
        return func.HttpResponse(
            body=json.dumps({"error": str(e)}),
            status_code=500,
            mimetype="application/json",
        )