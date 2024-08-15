from selenium import webdriver


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
    with ChromeDriver() as driver:
        driver.get('https://www.google.com/')
        print(driver.title)


main()
