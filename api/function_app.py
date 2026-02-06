import json
import os

import azure.functions as func
from azure.cosmos import CosmosClient, exceptions

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
    container = _get_container()

    doc_id = "site-visitors"
    pk = doc_id

    try:
        # atomic increment
        item = container.patch_item(
            item=doc_id,
            partition_key=pk,
            patch_operations=[{"op": "incr", "path": "/count", "value": 1}],
        )

        return func.HttpResponse(
            body=json.dumps({"count": item["count"]}),
            status_code=200,
            mimetype="application/json",
        )

    except exceptions.CosmosResourceNotFoundError:
        # creates item if none exists
        container.create_item({"id": doc_id, "count": 1})
        return func.HttpResponse(
            body=json.dumps({"count": 1}),
            status_code=200,
            mimetype="application/json",
        )

    except Exception as e:
        return func.HttpResponse(
            body=json.dumps({"error": str(e)}),
            status_code=500,
            mimetype="application/json",
        )