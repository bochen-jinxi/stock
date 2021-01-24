from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import re
import time
import json
 
caps = DesiredCapabilities.CHROME
caps['loggingPrefs'] = {'performance': 'ALL'}
driver = webdriver.Chrome(desired_capabilities=caps)
 
with open('num.txt','r')as p:
    num = p.readlines()
f = open('url.txt','w+')
 
def login():
    driver.get('http://www.itlaoqi.com/login.html')
    driver.find_element_by_xpath('/html/body/div/div/div[2]/div/form/div[2]/input').send_keys('17828161551')
    #driver.find_element_by_xpath('/html/body/div/div/div[2]/div/form/div[2]/input').send_keys('0727')
	driver.find_element_by_xpath('//*[@id="verifyCode"]').send_keys('0727')
    driver.find_element_by_xpath('//*[@id="btnSubmit"]').click()
    time.sleep(5)
 
def get_url():

    for i in num:
        try:
            driver.get('http://www.itlaoqi.com/chapter/{}.html'.format(str(i.strip())))
            driver.find_element_by_tag_name('body').send_keys(Keys.SPACE)
            time.sleep(5)
            lo = driver.get_log('performance')
            for entry in lo:
                try:
                    m = str(json.loads(entry['message'])['message']["params"])
                    url = re.search('http://video.itlaoqi.com/sv/.*?mp4', m).group()
                    print(url)
                    f.write(url + '\n')
                    break
                except Exception as e:
                    continue
        except:
            pass
        finally:
            f.close()
 
if __name__ == '__main__':
    login()
    get_url()