import requests
import os

# Configuration
URL = "http://127.0.0.1:5000/predict"
IMAGE_PATH = r"c:\Users\Karthik N\OneDrive\Desktop\Rubber_leaf\Rubber_Leaf_Dataset\Rubber_Leaf_Dataset\Compressed_Dataset\Anthracnose\anthracnose_1.jpg"

def test_prediction():
    if not os.path.exists(IMAGE_PATH):
        print(f"Error: Image not found at {IMAGE_PATH}")
        return

    print(f"Sending request to {URL} with image {IMAGE_PATH}...")
    
    with open(IMAGE_PATH, 'rb') as img:
        files = {'image': img}
        try:
            response = requests.post(URL, files=files)
            if response.status_code == 200:
                print("Success! Prediction Results:")
                print(response.json())
            else:
                print(f"Failed with status code: {response.status_code}")
                print(response.text)
        except Exception as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    test_prediction()
