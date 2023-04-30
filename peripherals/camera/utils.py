import os
from azure.storage.blob import BlobServiceClient
from dotenv import load_dotenv

load_dotenv()

AZURE_STORAGE_URL = "https://stcatdetector.blob.core.windows.net"
AZURE_STORAGE_CONTAINER_NAME = "images"


def create_detections_folder():
    output_folder = "./detections"
    folder_exists = os.path.isdir(output_folder)
    if not folder_exists:
        os.makedirs(output_folder)


def upload_image_to_azure(img_path):
    connection = os.getenv("AZURE_STORAGE_CONNECTION")
    service_client = BlobServiceClient.from_connection_string(connection)
    img_name = img_path.split('/')[-1]
    blob_client = service_client.get_blob_client(
        container=AZURE_STORAGE_CONTAINER_NAME, blob=img_name)

    with open(file=img_path, mode="rb") as data:
        blob_client.upload_blob(data)
