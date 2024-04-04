import fitz
import os
from PIL import Image

file_path = "D:/Downloads/lecture.pdf"

pdf_file = fitz.open(file_path)

page_nums = len(pdf_file)

images_list = []

for page_num in range(page_nums):
    page_content = pdf_file[page_num]
    images_list.extend(page_content.get_images())

print(images_list)

if len(images_list)==0:
    raise ValueError(f'No images found in {file_path}')

for i, image in enumerate(images_list, start=1):
    xref = image[0]
    base_image = pdf_file.extract_image(xref)

    image_bytes = base_image['image']
    image_ext = base_image['ext']

    image_name = str(i) + '.' + image_ext

    with open(os.path.join('images/', image_name), 'wb') as image_file:
        image_file.write(image_bytes)
        image_file.close()