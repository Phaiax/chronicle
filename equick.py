import pyautogui
import pyperclip
import time
from pynput import mouse

def on_click(x, y, button, pressed):
    if button == mouse.Button.middle and pressed:
        handle_text()

def handle_text():
    time.sleep(0.4)
    # Step 1: Get the currently selected text
    pyautogui.hotkey('command', 'c', interval=0.1)  # Copy selected text to clipboard
    time.sleep(0.1)  # Wait for the clipboard to be updated
    selected_text = pyperclip.paste()

    # Step 2: Delete the selected text
    pyautogui.press('delete')
    time.sleep(0.1)
    # Step 3: Select all text
    pyautogui.hotkey('command', 'a', interval=0.1)
    time.sleep(0.1)

    # Step 4: Save all selected text into a variable
    pyautogui.hotkey('command', 'c', interval=0.1)
    time.sleep(0.1)
    all_text = pyperclip.paste()

    # Step 5: Go to the start of the document
    pyautogui.hotkey('command', 'up', interval=0.1)
    time.sleep(0.1)

    # Step 6: Paste the reversed text
    reversed_text = selected_text[::-1]
    pyperclip.copy(reversed_text)
    pyautogui.hotkey('command', 'v', interval=0.1)
    time.sleep(0.1)
    pyautogui.press('enter', interval=0.1)

    time.sleep(0.1)

def main():
    # Start listening for mouse events
    with mouse.Listener(on_click=on_click) as listener:
        listener.join()

if __name__ == "__main__":
    main()
