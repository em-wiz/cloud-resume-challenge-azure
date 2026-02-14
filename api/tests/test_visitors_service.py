from azure.cosmos import exceptions
from api.src.visitors_service import increment_counter


def test_increment_existing_item(mocker):
    container = mocker.Mock()
    container.patch_item.return_value = {"count": 5}

    result = increment_counter(container)

    assert result == 5
    container.patch_item.assert_called_once()
    container.create_item.assert_not_called()


def test_increment_creates_item_if_missing(mocker):
    container = mocker.Mock()
    container.patch_item.side_effect = exceptions.CosmosResourceNotFoundError(
        message="not found",
        response=None,
    )

    result = increment_counter(container)

    assert result == 1
    container.create_item.assert_called_once_with({"id": "site-visitors", "count": 1})