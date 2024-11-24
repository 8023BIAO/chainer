# chainer

 [中文简体](#zh_CN) | [English - United States](#en_US) | [Russian](#ru) | [Português - Brasil](#pt_BR) | [Arabic](#ar) | [Ukrainian](#uk)

---

<a name="zh_CN"></a>

## 一、脚本概述

本脚本旨在为使用 GG（GameGuardian）进行游戏内存分析的用户提供一系列实用的功能，帮助他们更高效地搜索内存中的数据链、解析相关信息以及进行文件对比等操作，支持 32 位和 64 位游戏，并且使用 GG101 原版函数，具备良好的兼容性，可在其他兼容版本的 GG 上运行。

此脚本是使用 Lua 语言编写，在性能方面确实比不上用 C++编写的工具。它依然具有一定的实用性，能够为游戏内存分析提供一定的帮助，勉强可以满足部分用户的需求。

## 二、功能介绍

1. **搜索指针**：
    - 用户设定的搜索深度、偏移量、限制等参数，在指定内存范围内搜索数据链，最终根据用户选择的输出方式（如输出表文件、校验文件或两者皆输出）将搜索结果进行保存，方便后续分析内存结构以及定位目标地址。
    - 例如，用户可以根据游戏特定的数据特征，设定合适的参数，来查找游戏中关键数据结构的内存地址，像是角色属性、道具数量等相关的内存指针所在位置。

2. **解析文件**：
    - 允许用户指定一个包含链路信息的表指针文件，脚本会解析该文件并生成可用于获取目标地址的代码片段，同时提供复制偏移、运行代码或者输出完整代码到文件等操作选项，便于用户进一步利用获取到的链路信息进行内存操作。
    - 比如，当用户已经知晓某个游戏内数据结构的链路存储在一个文件中时，利用此功能就能便捷地获取到对应实际的内存地址，进而进行修改等操作。

3. **文件对比**：
    - 提供了两种文件对比模式，分别是“按表对比”和“按行对比”。
  
    - “按表对比” 模式下，会读取两个包含链路数据的 Lua 文件，对比其中的数据链信息，统计相同链的数量，并根据对比结果保存差异信息到输出文件中，方便用户查看数据变化情况。

    - “按行对比” 模式则是逐行读取两个普通文本文件内容，根据用户设置的是否对比不同选项，筛选出不同的行并保存到输出文件，适用于简单文本格式的数据对比场景。

## 三、输出文件格式说明

1. **输出锁链为无法执行 table 文件**：
    - **优点**：输出速度相对较快，能够迅速将搜索到的数据链以表格形式保存下来，对于只需获取基础数据，后续再进行针对性解析的情况较为实用。
    - **缺点**：生成的文件本身无法直接执行，若要进一步分析其中的链表信息，需要回到脚本中重新进行解析操作，操作步骤相对繁琐一些。

2. **输出锁链为可执行校验过滤文件**：
    - **优点**：不仅可以查看完整的数据链表结构，方便深入分析内存中数据的关联情况，而且文件本身具备可执行性，能够进行校验过滤等操作。基于文件内存储的链表信息，无需再次手动查找目标地址，甚至可以通过嵌套的方式找出链表指向目标的锁链表，对于复杂的内存数据追踪非常有帮助。
    - **缺点**：在解析链表过程中会消耗大量的内存资源，并且花费较多的时间进行处理，导致整体输出速度较慢，特别是在处理大规模数据时，可能会出现性能瓶颈。

## 参考项目

本脚本的开发参考了以下相关项目(排名不分先后)：

1. [RChainer](https://github.com/ht0Ruial/RChainer/)
2. [Chainer v0.2 GG 官方原版](https://gameguardian.net/forum/files/file/1409-chainer/)
3. bilibili [UID273134609](https://space.bilibili.com/273134609/) 用户的脚本

## 贡献与反馈

欢迎开发者以及游戏内存分析爱好者使用本脚本。同时，鼓励大家积极提供有价值的建议和反馈，以帮助我改进脚本功能，使其能更好地服务于游戏内存分析需求

## 免责声明

本脚本仅用于学习交流。请谨慎使用，并且在修改任何游戏数据前，确保已获得必要的权限。

## 使用步骤

1. 从 [仓库链接](https://github.com/8023BIAO/chainer/archive/refs/heads/main.zip) 下载脚本。
2. 将下载内容解压到你想要存放的目录中。
3. 在将 GG（游戏守护者）挂载到游戏的情况下。
4. 在保存列表勾选要扫描的一个项目
5. 运行 `chainer.lua` 点击 搜索指针
6. 设置参数 点击确定 等待搜索结果输出

---

<a name="en_US"></a>

## One. Script Overview

This script aims to provide a series of practical functions for users who use GG (GameGuardian) for game memory analysis, helping them to search memory data chains more efficiently, parse relevant information, and compare files, etc. It supports both 32-bit and 64-bit games and uses GG101 original functions, ensuring good compatibility and the ability to run on other compatible versions of GG.

The script is written in Lua language. Although its performance may not match tools written in C++, it still has practical utility and can provide certain assistance for game memory analysis, barely meeting the needs of some users.

## Two. Function Introduction

1. **Search Pointer**:
    - Users can set search depth, offset, limits, and other parameters to search for data chains within the specified memory range. According to the user's chosen output method (such as outputting table files, checksum files, or both), the search results are saved for subsequent analysis of memory structure and location of target addresses.
    - For example, users can set appropriate parameters based on specific game data characteristics to find the memory addresses of key game data structures, such as character attributes, item quantities, and related memory pointer locations.

2. **Parse File**:
    - Allows users to specify a table pointer file containing chain information. The script will parse the file and generate code snippets that can be used to obtain target addresses, providing options to copy offsets, run code, or output complete code to a file, facilitating further memory operations using the obtained chain information.
    - For instance, when a user knows that the chain of a game's internal data structure is stored in a file, this feature can conveniently obtain the actual memory address for modification and other operations.

3. **File Comparison**:
    - Provides two file comparison modes: "Compare by Table" and "Compare by Line".
  
    - In "Compare by Table" mode, it reads two Lua files containing chain data, compares the data chain information, counts the number of identical chains, and saves the difference information to an output file based on the comparison results, making it easy for users to view data changes.

    - "Compare by Line" mode reads two plain text files line by line, filters out different lines based on user settings, and saves them to an output file, suitable for simple text format data comparison scenarios.

## Three. Output File Format Description

1. **Output chain as non-executable table file**:
    - **Advantages**: The output speed is relatively fast, quickly saving the searched data chains in tabular form, which is practical for situations where only basic data is needed and subsequent targeted parsing is performed.
    - **Disadvantages**: The generated file cannot be executed directly. To further analyze the chain information, one must return to the script and perform parsing operations, which is relatively cumbersome.

2. **Output chain as executable checksum filter file**:
    - **Advantages**: Not only can you view the complete data chain table structure for in-depth analysis of the correlation of data in memory, but the file itself is executable and capable of checksum filtering operations. Based on the chain information stored in the file, there is no need to manually find the target address again, and nested methods can even be used to find the chain table that points to the target, which is very helpful for complex memory data tracking.
    - **Disadvantages**: The process of parsing the chain table consumes a lot of memory resources and takes a considerable amount of time, resulting in a slow overall output speed, especially when dealing with large-scale data, which may lead to performance bottlenecks.

## Reference Projects

The development of this script refers to the following related projects (unordered):

1. [RChainer](https://github.com/ht0Ruial/RChainer/)
2. [Chainer v0.2 GG Official Original](https://gameguardian.net/forum/files/file/1409-chainer/)
3. bilibili [UID273134609](https://space.bilibili.com/273134609/) user's script

## Contribution and Feedback

We welcome developers and game memory analysis enthusiasts to use this script. At the same time, we encourage everyone to actively provide valuable suggestions and feedback to help us improve the script's functionality, making it better serve the needs of game memory analysis.

## Disclaimer

This script is for learning and communication purposes only. Please use it with caution and ensure that you have the necessary permissions before modifying any game data.

## Usage Steps

1. Download the script from [repository link](https://github.com/8023BIAO/chainer/archive/refs/heads/main.zip).
2. Unzip the downloaded content to the directory where you want to store it.
3. With GG (GameGuardian) mounted to the game.
4. Check one item in the save list that you want to scan.
5. Run `chainer.lua` and click "Search Pointer".
6. Set parameters, click "OK", and wait for the search results to be output.

---

<a name="ru"></a>

## Один. Обзор сценария

Этот скрипт предназначен для предоставления ряда практических функций пользователям, использующим GG (GameGuardian) для анализа игровой памяти, помогая им более эффективно искать цепочки данных в памяти, анализировать соответствующую информацию и сравнивать файлы и т. д. Он поддерживает как 32-битные, так и 64-битные игры и использует оригинальные функции GG101, обеспечивая хорошую совместимость и возможность запуска на других совместимых версиях GG.

Скрипт написан на языке Lua. Хотя его производительность может не соответствовать инструментам, написанным на C++, он все же имеет практическую полезность и может оказать определенную помощь в анализе игровой памяти, едва удовлетворяя потребности некоторых пользователей.

## Два. Введение в функции

1. **Поиск указателя**:
    - Пользователи могут установить глубину поиска, смещение, ограничения и другие параметры для поиска цепочек данных в указанном диапазоне памяти. В соответствии с выбранным пользователем способом вывода (например, вывод таблицы файлов, файлов проверки суммы или обоих), результаты поиска сохраняются для последующего анализа структуры памяти и определения адресов целевых объектов.
    - Например, пользователи могут установить соответствующие параметры на основе конкретных характеристик данных игры, чтобы найти адреса памяти ключевых структур данных игры, таких как характеристики персонажа, количество предметов и связанные с ними адреса указателей памяти.

2. **Разбор файла**:
    - Позволяет пользователю указать файл указателя таблицы, содержащий информацию о цепочке. Скрипт будет анализировать этот файл и генерировать фрагменты кода, которые можно использовать для получения адресов целевых объектов, предоставляя варианты копирования смещений, выполнения кода или вывода полного кода в файл, облегчая дальнейшие операции с памятью с использованием полученной информации о цепочке.
    - Например, когда пользователь уже знает, что цепочка внутренней структуры данных игры хранится в файле, эту функцию можно удобно использовать для получения фактического адреса памяти для изменения и других операций.

3. **Сравнение файлов**:
    - Предлагает два режима сравнения файлов: "Сравнение по таблице" и "Сравнение по строке".

    - В режиме "Сравнение по таблице" он считывает два файла Lua, содержащих информацию о цепочке данных, сравнивает информацию о цепочке данных, подсчитывает количество одинаковых цепочек и сохраняет информацию об отличиях в выходной файл на основе результатов сравнения, что удобно для пользователей при просмотре изменений данных.

    - Режим "Сравнение по строке" считывает содержимое двух обычных текстовых файлов по строке, фильтрует разные строки на основе настроек пользователя и сохраняет их в выходной файл, подходящий для сравнения данных в простом текстовом формате.

## Три. Описание формата выходного файла

1. **Выходная цепочка в виде неисполняемого файла таблицы**:
    - **Преимущества**: Скорость вывода относительно высока, быстро сохраняет найденные цепочки данных в виде таблицы, что практично для ситуаций, когда требуется получить только базовые данные, а затем выполнить целевой анализ.
    - **Недостатки**: Сгенерированный файл сам по себе не может быть выполнен напрямую. Чтобы дальше анализировать информацию о цепочке, необходимо вернуться к скрипту и выполнить операции анализа, что относительно хлопотно.

2. **Выходная цепочка в виде исполняемого файла фильтра проверки суммы**:
    - **Преимущества**: Вы не только можете просмотреть полную структуру таблицы данных цепочки для глубокого анализа связи данных в памяти, но и сам файл исполняем и способен выполнять операции фильтрации проверки суммы. Исходя из информации о цепочке, хранящейся в файле, нет необходимости снова вручную искать адрес целевого объекта, и даже можно использовать вложенные методы для нахождения таблицы цепочек, указывающих на целевой объект, что очень полезно для сложного отслеживания данных памяти.
    - **Недостатки**: Процесс анализа таблицы цепочек потребляет много памяти и занимает довольно много времени, что приводит к медленной общей скорости вывода, особенно при работе с крупномасштабными данными, что может привести к производственным узким местам.

## Ссылки на проекты для справки

Разработка этого скрипта ссылается на следующие связанные проекты (в любом порядке):

1. [RChainer](https://github.com/ht0Ruial/RChainer/)
2. [Chainer v0.2 GG Официальная оригинальная версия](https://gameguardian.net/forum/files/file/1409-chainer/)
3. Скрипт пользователя bilibili [UID273134609](https://space.bilibili.com/273134609/)

## Вклад и обратная связь

Мы приветствуем разработчиков и любителей анализа игровой памяти использовать этот скрипт. В то же время мы поощряем всех активно предоставлять ценные предложения и обратную связь, чтобы помочь нам улучшить функциональность скрипта и сделать его лучше служить потребностям анализа игровой памяти.

## Отказ от ответственности

Этот скрипт предназначен только для обучения и общения. Пожалуйста, используйте его осторожно и убедитесь, что у вас есть необходимые разрешения перед изменением любых игровых данных.

## Шаги использования

1. Скачайте скрипт с [ссылки на репозиторий](https://github.com/8023BIAO/chainer/archive/refs/heads/main.zip).
2. Разархивируйте скачанный контент в каталог, где вы хотите его сохранить.
3. При подключенном GG (GameGuardian) к игре.
4. Отметьте элемент в списке сохранений, который вы хотите сканировать.
5. Запустите `chainer.lua` и нажмите "Искать указатель".
6. Установите параметры, нажмите "OK" и дождитесь вывода результатов поиска.

---

<a name="pt_BR"></a>

## Um. Visão Geral do Roteiro

Este script visa fornecer uma série de funções práticas para usuários que usam GG (GameGuardian) para análise de memória de jogos, ajudando-os a procurar cadeias de dados na memória de forma mais eficiente, analisar informações relevantes e comparar arquivos, etc. Ele suporta jogos de 32 e 64 bits e usa funções originais GG101, garantindo boa compatibilidade e a capacidade de ser executado em outras versões compatíveis do GG.

O script é escrito em Lua. Embora seu desempenho possa não corresponder a ferramentas escritas em C++, ele ainda possui utilidade prática e pode oferecer certa ajuda na análise de memória de jogos, mal atendendo às necessidades de alguns usuários.

## Dois. Introdução às Funções

1. **Procurar Ponteiro**:
    - Os usuários podem definir profundidade de busca, deslocamento, limites e outros parâmetros para procurar cadeias de dados dentro de um intervalo de memória especificado. De acordo com o método de saída escolhido pelo usuário (como saída de arquivos de tabela, arquivos de verificação ou ambos), os resultados da busca são salvos para análise subsequente da estrutura de memória e localização de endereços de destino.
    - Por exemplo, os usuários podem definir parâmetros apropriados com base nas características específicas dos dados do jogo para encontrar os endereços de memória das estruturas de dados-chave do jogo, como atributos do personagem, quantidade de itens e locais relacionados de ponteiros de memória.

2. **Analisar Arquivo**:
    - Permite que os usuários especifiquem um arquivo de ponteiro de tabela contendo informações de cadeia. O script analisará esse arquivo e gerará trechos de código que podem ser usados para obter endereços de destino, fornecendo opções como copiar deslocamentos, executar código ou sair do código completo para um arquivo, facilitando operações adicionais de memória usando as informações de cadeia obtidas.
    - Por exemplo, quando o usuário já sabe que a cadeia de uma estrutura de dados interna do jogo está armazenada em um arquivo, essa função pode ser usada convenientemente para obter o endereço real da memória para modificação e outras operações.

3. **Comparação de Arquivos**:
    - Oferece dois modos de comparação de arquivos: "Comparar por Tabela" e "Comparar por Linha".

    - No modo "Comparar por Tabela", ele lê dois arquivos Lua contendo informações de cadeia de dados, compara as informações da cadeia de dados, conta o número de cadeias idênticas e salva as informações das diferenças em um arquivo de saída com base nos resultados da comparação, facilitando para os usuários visualizarem mudanças nos dados.

    - O modo "Comparar por Linha" lê o conteúdo de dois arquivos de texto comuns linha por linha, filtra linhas diferentes com base nas configurações do usuário e as salva em um arquivo de saída, adequado para cenários de comparação de dados em formato de texto simples.

## Três. Descrição do Formato do Arquivo de Saída

1. **Saída da cadeia como arquivo de tabela não executável**:
    - **Vantagens**: A velocidade de saída é relativamente rápida, salvando rapidamente as cadeias de dados encontradas na forma de uma tabela, o que é prático para situações em que apenas dados básicos são necessários e análise direcionada subsequente é realizada.
    - **Desvantagens**: O arquivo gerado não pode ser executado diretamente. Para analisar mais a informação da cadeia, é necessário voltar ao script e realizar operações de análise, o que é relativamente complicado.

2. **Saída da cadeia como arquivo de filtro de verificação executável**:
    - **Vantagens**: Você não só pode visualizar a estrutura completa da tabela de dados da cadeia para análise aprofundada da relação de dados na memória, mas o próprio arquivo é executável e capaz de operações de filtro de verificação. Com base nas informações da cadeia armazenadas no arquivo, não há necessidade de procurar manualmente o endereço do destino novamente, e até mesmo métodos aninhados podem ser usados para encontrar a tabela da cadeia que aponta para o destino, o que é muito útil para rastreamento complexo de dados de memória.
    - **Desvantagens**: O processo de análise da tabela da cadeia consome muitos recursos de memória e leva um tempo considerável para processar, resultando em uma velocidade de saída lenta, especialmente ao lidar com dados em larga escala, o que pode levar a gargalos de desempenho.

## Projetos de Referência

O desenvolvimento deste script refere-se aos seguintes projetos relacionados (em qualquer ordem):

1. [RChainer](https://github.com/ht0Ruial/RChainer/)
2. [Chainer v0.2 GG Versão Oficial Original](https://gameguardian.net/forum/files/file/1409-chainer/)
3. Script do usuário bilibili [UID273134609](https://space.bilibili.com/273134609/)

## Contribuição e Feedback

Congratulamos desenvolvedores e entusiastas da análise de memória de jogos por usarem este script. Ao mesmo tempo, encorajamos todos a fornecer ativamente sugestões e feedback valiosos para nos ajudar a melhorar a funcionalidade do script, tornando-o melhor para atender às necessidades de análise de memória de jogos.

## Isenção de Responsabilidade

Este script é apenas para fins de aprendizado e comunicação. Por favor, use-o com cautela e certifique-se de ter as permissões necessárias antes de modificar quaisquer dados do jogo.

## Etapas de Uso

1. Baixe o script do [link do repositório](https://github.com/8023BIAO/chainer/archive/refs/heads/main.zip).
2. Descompacte o conteúdo baixado para o diretório onde deseja armazená-lo.
3. Com o GG (GameGuardian) montado no jogo.
4. Marque um item na lista de salvamentos que deseja digitalizar.
5. Execute `chainer.lua` e clique em "Procurar Ponteiro".
6. Defina os parâmetros, clique em "OK" e aguarde a saída dos resultados da busca.

---

<a name="ar"></a>

## أربعة. نظرة عامة على السيناريو

هذا السيناريو مصمم لتوفير مجموعة من الوظائف العملية للمستخدمين الذين يستخدمون GG (GameGuardian) لتحليل ذاكرة الألعاب، ويساعدهم على البحث بشكل أكثر كفاءة في سلاسل بيانات الذاكرة، وتحليل المعلومات ذات الصلة، ومقارنة الملفات، إلخ. يدعم الألعاب التي تعمل بنظامي 32 و64 بت، ويستخدم وظائف GG101 الأصلية، مما يضمن توافقًا جيدًا والقدرة على التشغيل على إصدارات GG المتوافقة الأخرى.

السيناريو مكتوب بلغة Lua. على الرغم من أن أدائه قد لا يضاهي الأدوات المكتوبة بلغة C++، إلا أنه لا يزال يتمتع بفائدة عملية ويمكن أن يقدم بعض المساعدة في تحليل ذاكرة الألعاب، ويكاد يلبي احتياجات بعض المستخدمين.

## خمسة. مقدمة إلى الوظائف

1. **البحث عن المؤشر**:
    - يمكن للمستخدمين تحديد عمق البحث، والإزاحة، والحدود، وغيرها من المعلمات للبحث عن سلاسل البيانات داخل نطاق ذاكرة محدد، ووفقًا لطريقة الإخراج التي يختارها المستخدم (مثل إخراج ملفات الجدول، أو ملفات التحقق، أو كلاهما)، يتم حفظ نتائج البحث لتحليل هيكل الذاكرة وتحديد عناوين الأهداف لاحقًا.
    - على سبيل المثال، يمكن للمستخدمين تحديد المعلمات المناسبة بناءً على خصائص بيانات اللعبة المحددة للبحث عن عناوين ذاكرة هياكل البيانات الرئيسية في اللعبة، مثل خصائص الشخصية، وعدد العناصر، ومواقع مؤشرات الذاكرة ذات الصلة.

2. **تحليل الملف**:
    - يسمح للمستخدمين بتحديد ملف مؤشر الجدول الذي يحتوي على معلومات السلسلة، وسيقوم السيناريو بتحليل هذا الملف وإنشاء قطع من الكود التي يمكن استخدامها للحصول على عناوين الأهداف، مع توفير خيارات مثل نسخ الإزاحات، تشغيل الكود، أو إخراج الكود الكامل إلى ملف، مما يسهل على المستخدمين استخدام المعلومات المحصلة عن السلسلة لعمليات الذاكرة الإضافية.
    - على سبيل المثال، عندما يعرف المستخدم بالفعل أن سلسلة هيكل البيانات الداخلية للعبة مخزنة في ملف، يمكن استخدام هذه الوظيفة بشكل مريح للحصول على العنوان الفعلي للذاكرة للتعديل وغيرها من العمليات.

3. **مقارنة الملفات**:
    - يوفر نمطين لمقارنة الملفات، وهما "المقارنة حسب الجدول" و"المقارنة حسب السطر".

    - في وضع "المقارنة حسب الجدول"، يقرأ الملفان Lua اللذان يحتويان على معلومات سلسلة البيانات، ويقارن المعلومات، ويحسب عدد السلاسل المتطابقة، ويحفظ المعلومات المختلفة في ملف الإخراج بناءً على نتائج المقارنة، مما يسهل على المستخدمين مشاهدة التغيرات في البيانات.

    - أما وضع "المقارنة حسب السطر" فيقرأ محتوى ملفين نصيين عاديين سطرًا بسطر، ويفلتر السطور المختلفة بناءً على إعدادات المستخدم، ويحفظها في ملف الإخراج، وهو مناسب لسيناريوهات مقارنة البيانات بتنسيق نصي بسيط.

## ستة. وصف تنسيق ملف الإخراج

1. **إخراج السلسلة كملف جدول غير قابل للتنفيذ**:
    - **المزايا**: سرعة الإخراج نسبيًا سريعة، ويمكن حفظ سلاسل البيانات المكتشفة بسرعة في شكل جدول، وهو مفيد للحالات التي تحتاج فقط إلى الحصول على البيانات الأساسية، ثم إجراء التحليل الموجه لاحقًا.
    - **العيوب**: الملف المولد لا يمكن تنفيذه مباشرة. لمزيد من تحليل معلومات السلسلة، يجب العودة إلى السيناريو وإجراء عمليات التحليل، وهو ما يعتبر إجراءً معقدًا نسبيًا.

2. **إخراج السلسلة كملف فلتر التحقق القابل للتنفيذ**:
    - **المزايا**: لا يمكنك فقط مشاهدة الهيكل الكامل لجدول بيانات السلسلة لتحليل عميق للعلاقات بين بيانات الذاكرة، ولكن الملف نفسه قابل للتنفيذ ويمكنه إجراء عمليات فلترة التحقق. استنادًا إلى المعلومات المخزنة في الملف عن السلسلة، لا حاجة للبحث يدويًا عن عنوان الهدف مرة أخرى، وحتى يمكن استخدام الطرق المتداخلة للعثور على جدول السلسلة الذي يشير إلى الهدف، وهو مفيد جدًا لتتبع بيانات الذاكرة المعقد.

    - **العيوب**: عملية تحليل جدول السلسلة تستهلك الكثير من موارد الذاكرة وتستغرق وقتًا طويلًا للمعالجة، مما يؤدي إلى بطء سرعة الإخراج الكلية، خاصة عند التعامل مع بيانات واسعة النطاق، مما قد يؤدي إلى نقاط ضعف في الأداء.

## المشاريع المرجعية

تم تطوير هذا السيناريو مع الرجوع إلى المشاريع ذات الصلة التالية (بدون ترتيب):

1. [RChainer](https://github.com/ht0Ruial/RChainer/)
2. [Chainer v0.2 GG النسخة الأصلية الرسمية](https://gameguardian.net/forum/files/file/1409-chainer/)
3. سيناريو المستخدم في bilibili [UID273134609](https://space.bilibili.com/273134609/)

## المساهمة والتعليقات

نرحب المطورين وعشاق تحليل ذاكرة الألعاب لاستخدام هذا السيناريو. في الوقت نفسه، نشجع الجميع على تقديم اقتراحات وتعليقات قيمة بنشاط لمساعدتنا على تحسين وظائف السيناريو، مما يجعله أفضل في خدمة احتياجات تحليل ذاكرة الألعاب.

## إخلاء المسؤولية

هذا السيناريو مخصص للتعلم والتواصل فقط. يرجى استخدامه بحذر وتأكد من حصولك على التصريحات اللازمة قبل تعديل أي بيانات لعبة.

## خطوات الاستخدام

1. انقر لتحميل السيناريو من [رابط المستودع](https://github.com/8023BIAO/chainer/archive/refs/heads/main.zip).
2. قم بفك ضغط المحتوى المنزل إلى الدليل الذي ترغب في تخزينه فيه.
3. مع تثبيت GG (GameGuardian) على اللعبة.
4. قم بتحديد عنصر واحد في قائمة الحفظ التي ترغب في مسحها ضوئيًا.
5. قم بتشغيل `chainer.lua` وانقر على "البحث عن المؤشر".
6. قم بتعيين المعلمات، انقر على "OK" وانتظر إخراج نتائج البحث.

---

<a name="uk"></a>

## Шість. Перегляд сценарію

Цей сценарій призначений для надання користувачам, які використовують GG (GameGuardian) для аналізу пам'яті відеоігор, набору практичних функцій, які допомагають їм більш ефективно шукати ланцюжки даних у пам'яті, аналізувати відповідну інформацію та порівнювати файли тощо. Він підтримує як 32-бітні, так і 64-бітні ігри та використовує оригінальні функції GG101, забезпечуючи хорошу сумісність та можливість запуску на інших сумісних версіях GG.

Сценарій написаний мовою Lua. Хоча його продуктивність може не досягати рівня інструментів, написаних мовою C++, він все ж має практичну користь і може надати деяку допомогу в аналізі пам'яті відеоігор, едва задовольняючи потреби деяких користувачів.

## Сім. Введення у функції

1. **Пошук вказівника**:
    - Користувачі можуть встановити глибину пошуку, зсув, обмеження та інші параметри для пошуку ланцюжків даних у визначеному діапазоні пам'яті. Залежно від методу виведення, обраним користувачем (наприклад, виведення таблиць файлів, файлів перевірки суми або обох), результати пошуку зберігаються для подальшого аналізу структури пам'яті та визначення адресів цільових об'єктів.
    - Наприклад, користувачі можуть встановити відповідні параметри на основі конкретних хара默тих даних гри для пошуку адресів пам'яті ключових структур даних гри, таких як характеристики персонажа, кількість предметів та пов'язані з ними адреси вказівників пам'яті.

2. **Аналіз файлу**:
    - Дозволяє користувачам вказати файл вказівника таблиці, що містить інформацію про ланцюжок. Сценарій проаналізує цей файл і згенерує фрагменти коду, які можна використати для отримання адресів цільових об'єктів, надаючи опції копіювання зсувів, виконання коду або виведення повного коду до файлу, спрощуючи подальші операції з пам'яттю за допомогою отриманої інформації про ланцюжок.
    - Наприклад, коли користувач вже знає, що ланцюжок внутрішньої структури даних гри зберігається у файлі, цю функцію можна зручно використати для отримання фактичного адресу пам'яті для модифікації та інших операцій.

3. **Порівняння файлів**:
    - Представляє два режими порівняння файлів: "Порівняння за таблицею" та "Порівняння за рядком".

    - У режимі "Порівняння за таблицею" він читає два файли Lua, що містять інформацію про ланцюжок даних, порівнює інформацію про ланцюжок даних, підраховує кількість однакових ланцюжків та зберігає інформацію про відмінності до файлу виведення на основі результатів порівняння, що спрощує користувачам перегляд змін у даних.

    - Режим "Порівняння за рядком" читає вміст двох звичайних текстових файлів рядок за рядком, фільтрує різні рядки на основі налаштувань користувача та зберігає їх до файлу виведення, підходить для порівняння даних у простому текстовому форматі.

## Вісім. Опис формату файлу виведення

1. **Виведення ланцюжка у вигляді неекзекутивного файлу таблиці**:
    - **Переваги**: Швидкість виведення відносно висока, швидко зберігає знайдені ланцюжки даних у вигляді таблиці, що практично для ситуацій, коли потрібно отримати тільки базові дані, а потім провести цільовий аналіз.
    - **Недоліки**: Створений файл сам по собі не може бути виконаний напряму. Для подальшого аналізу інформації про ланцюжок необхідно повернутися до сценарію та провести операції аналізу, що є відносно складним.

2. **Виведення ланцюжка у вигляді екзекутивного файлу фільтрування перевірки суми**:
    - **Переваги**: Ви не тільки можете переглянути повну структуру таблиці даних ланцюжка для глибокого аналізу зв'язку даних у пам'яті, але й сам файл є екзекутивним та здатний виконувати операції фільтрування перевірки суми. Основуючись на інформації про ланцюжок, збереженій у файлі, немає необхідності знову вручну шукати адресу цільового об'єкта, і навіть можна використовувати вкладені методи для знаходження таблиці ланцюжків, що вказують на цільовий об'єкт, що є дуже корисним для складного відстеження даних пам'яті.
    - **Недоліки**: Процес аналізу таблиці ланцюжка споживає багато пам'яті та займає досить багато часу для обробки, що призводить до повільної загальної швидкості виведення, особливо при роботі з великомасштабними даними, що може призвести до виникнення вузьких місць у продуктивності.

## Посилання на проекти для ознайомлення

Розробка цього сценарію посилається на наступні пов'язані проекти (без упорядку):

1. [RChainer](https://github.com/ht0Ruial/RChainer/)
2. [Chainer v0.2 GG Офіційна оригінальна версія](https://gameguardian.net/forum/files/file/1409-chainer/)
3. Сценарій користувача bilibili [UID273134609](https://space.bilibili.com/273134609/)

## Внесок та зворотний зв'язок

Ми привітні розробників та любителів аналізу пам'яті відеоігор використовувати цей сценарій. Водночасно ми заохочуємо всіх активно надавати цінні пропозиції та зворотний зв'язок, щоб допомогти нам покращити функціональність сценарію, зробивши його кращим у задоволенні потребам аналізу пам'яті відеоігор.

## Відмова від відповідальності

Цей сценарій призначений тільки для навчання та спілкування. Будь ласка, використовуйте його обережно та переконайтеся, що у вас є необхідні дозволи перед зміною будь-яких даних гри.

## Кроки використання

1. Завантажте сценарій з [посилання на репозиторій](https://github.com/8023BIAO/chainer/archive/refs/heads/main.zip).
2. Розпакуйте завантажений вміст до каталогу, де ви хочете його зберегти.
3. При підключеному GG (GameGuardian) до гри.
4. Позначте один елемент у списку збережень, який ви хочете сканувати.
5. Запустіть `chainer.lua` та натисніть "Пошук вказівника".
6. Встановіть параметри, натисніть "OK" та зачекайте виведення результатів пошуку.

