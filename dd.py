import vk_api
def captcha_handler(captcha):
    key = input("Enter Captcha {0}: ".format(captcha.get_url())).strip()
    return captcha.try_again(key)

def find_dogs(group_id, tools):
    ids = tools.get_all('groups.getMembers', 1000, {'group_id': group_id, 'fields' : 'users'})
    ids = ids['items']
    sobaki = []
    for sobaka in ids:
        try:
            if sobaka['deactivated'] == 'banned' or sobaka['deactivated'] == 'deleted':
                sobaki.append(sobaka['id'])
        except KeyError:
            pass
    return sobaki
def read_groups():
    group_list = []
    f=open('groups.txt', 'r')
    for line in f:
        group_list.append(line.strip())
    f.close
    return group_list
def resolve_name(vk, name):
    response = vk.utils.resolveScreenName(screen_name=name)
    group_id = response['object_id']
    return group_id
def main():
    group_list = read_groups()
    login = '88005553535'
    password = 'Йцукен1234567890'
    print('Loggin into ' + login)
    vk_session = vk_api.VkApi(login, password, captcha_handler=captcha_handler)
    vk = vk_session.get_api()
    try:
        vk_session.auth()
    except vk_api.AuthError as error_msg:
        print(error_msg)
        return
    tools = vk_api.VkTools(vk_session)
    #Поочередно собираем всех собак по списку групп из groups.txt и сразу удаляем
    for group in group_list:
        try:
            group = int(group)
        except:
            group = resolve_name(vk, group)
        print('Удаляем собак из ' + group)
        sobaki = find_dogs(group, tools)
        for sobaka in sobaki:
            vk.groups.removeUser(group_id=group, user_id=int(sobaka))
        print('Удалено: ', len(sobaki))
if __name__ == '__main__':
        main()