from ultralytics import YOLO
from datetime import datetime, timedelta
import cv2
from utils import upload_image_to_azure, create_detections_folder


TARGET_CLASS = "person"
COOLDOWN_DURATION = 10  # Minutes
cooldown_end = None  # Cooldown end datetime


def on_predict_batch_end(predictor):
    # https://docs.ultralytics.com/usage/callbacks/#callbacks
    global cooldown_end

    if cooldown_end is not None and datetime.now() < cooldown_end:
        return
    else:
        cooldown_end = None

    for result in predictor.results:
        for cls in result.boxes.cls:
            cls_name = model.names[int(cls)]
            if cls_name == TARGET_CLASS:
                cooldown_start = datetime.now()
                cooldown_end = cooldown_start + \
                    timedelta(minutes=COOLDOWN_DURATION)
                # Save image locally
                plot_img = result.plot()
                file_path = './detections/{}.png'.format(
                    cooldown_start.strftime("%Y-%m-%d-%H-%M-%S"))
                success = cv2.imwrite(file_path, plot_img)
                if success:
                    # Save image to storage account
                    upload_image_to_azure(file_path)


create_detections_folder()

model = YOLO("yolov8m.pt")
model.add_callback("on_predict_batch_end", on_predict_batch_end)
classes = [index for index in model.names if model.names[index] == TARGET_CLASS]
# https://docs.ultralytics.com/modes/predict/#arguments
results = model.predict(source="1", show=True, verbose=False,
                        conf=0.9, classes=classes, save=True)
