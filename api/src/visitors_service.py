from azure.cosmos import exceptions


def increment_counter(container, doc_id: str = "site-visitors") -> int:
    """
    Core business logic for the visitor counter.

    - Performs atomic increment using Cosmos DB PATCH.
    - Creates the document if it does not exist.
    - Returns the updated visitor count.

    Extracted from Azure Function handler to enable unit testing.
    """

    pk = doc_id  # partition key matches document id

    try:
        item = container.patch_item(
            item=doc_id,
            partition_key=pk,
            patch_operations=[{"op": "incr", "path": "/count", "value": 1}],
        )
        return int(item["count"])

    except exceptions.CosmosResourceNotFoundError:
        container.create_item({"id": doc_id, "count": 1})
        return 1