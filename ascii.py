from PIL import Image
import sys
ascii_char = list("$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,\"^`'. ")

def get_char(r,g,b,alpha = 256):
    if alpha == 0:
        return ' '
    gray = int(0.2126 * r + 0.7152 * g + 0.0722 * b)
    return ascii_char[int(gray/(256+1)*len(ascii_char))]



if __name__=='__main__':
    IMG = sys.argv[1]
    width = int(sys.argv[2])
    height = int(sys.argv[3])
    im = Image.open(IMG)
    im = im.resize((width,height))
    txt = ""
    for i in range(height):
        for j in range(width):
           txt += get_char(*im.getpixel((j,i)))
        txt += '\n'
    print(txt)
    with open('test.txt','w') as f:
        f.write(txt)

