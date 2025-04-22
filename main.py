import logging
import time
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By


class ChromeDriver:
    def __enter__(self):
        options = webdriver.ChromeOptions()
        # 必須
        options.add_argument('--headless=new')
        # 必須 「session not created: DevToolsActivePort file doesn't exist」と言われる
        options.add_argument('--no-sandbox')

        self.driver = webdriver.Chrome(options=options)
        self.driver.set_window_size(1920, 1080)
        return self.driver

    def __exit__(self, exc_type, exc_value, tb):
        self.driver.quit()


def main():
    for _ in range(2):
        with ChromeDriver() as driver:
            driver.get('https://checkip.amazonaws.com/')
            ip_text = WebDriverWait(driver, 10).until(
                lambda d: d.find_element(by=By.XPATH, value='/html/body').text,
                '見つかりません',
            )
            logging.info(f'IPアドレス: {ip_text}')
            print(f'IPアドレス: {ip_text}')
            time.sleep(2)



main()
