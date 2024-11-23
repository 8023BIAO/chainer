local dofile = dofile
local io = io
local ipairs = ipairs
local load = load
local loadfile = loadfile
local next = next
local os = { clock = os.clock }
local pairs = pairs
local print = print
local table = table
local string = string

local gg = require 'gg'

local main
local config
local filePath = gg.getFile()
local targetInfo = gg.getTargetInfo()
local targetPackage = gg.getTargetPackage()
local is64Bit = targetInfo.x64
local targetProcessName = targetInfo.label
local configFilePath = filePath:match('(.*/)') .. 'config.lua'
local paddingValue = is64Bit and 0xFFFFFFFFFFFFFFFF or 0xFFFFFFFF

local chunk = loadfile(configFilePath)
if chunk then config = chunk() end
config = config or {}
config[targetPackage] = config[targetPackage] or {}

local RANGES_CODE = {
  [1] = 1048576,
  [2] = 524288,
  [3] = 262144,
  [4] = 131072,
  [5] = 65536,
  [6] = 32768,
  [7] = 16384,
  [8] = 64,
  [9] = 32,
  [10] = 16,
  [11] = 8,
  [12] = 4,
  [13] = 2,
  [14] = 1,
  [15] = -2080896
};

local RANGES_SELECT = {
  [1] = 'V',
  [2] = 'As',
  [3] = 'PS',
  [4] = 'B',
  [5] = 'J',
  [6] = 'Xs',
  [7] = 'Xa',
  [8] = 'S',
  [9] = 'A',
  [10] = 'Cb',
  [11] = 'Cd',
  [12] = 'Ca',
  [13] = 'Jh',
  [14] = 'Ch',
  [15] = 'O'
};

local staticHeaderState = { 'Cd', 'Cb', 'Xa', 'PS' }

local localeTable = {
  ['zh_CN'] = {
    '返回', '无链路可用', '耗时', '选择链路输出',
    '复制偏移', '运行', '输出完整代码', '表文件:',

    '校验文件:', '未在保存列表选中一项',
    '未搜索到符合条件的头文件 建议检查并修改头文件匹配规则',

    '深度:', '偏移:', '每层限制:', '扫到停止:', '起始地址:',
    '结束地址:', '输出文件:', '输出为表文件', '输出为校验文件',

    '未选择输出文件', '未选择头文件',
    '链路:', '搜索耗时:', '输出耗时:',

    '文件1:', '文件2:',

    '对比不同',

    '按表对比', '按行对比', '不支持的模式',
    '不存在', '匹配文件头',

    '搜索指针', '解析文件', '文件对比',

    '需要重新选择进程',
  },
  ['en_US'] = {
    'back', 'no chains', 'time', 'select chain output',
    'copy offsets', 'run', 'output full code', 'table file:',

    'check file:', 'not selected in the save list',
    'No matching header files found. Please check and modify the header file matching rules.',

    'depth:', 'offset:', 'limit per layer:', 'scan to stop:', 'start address:',
    'end address:', 'output file:', 'output to table file', 'output to check file',

    'output file not selected', 'header file not selected',
    'chains:', 'search time:', 'output time:',

    'file1:', 'file2:',

    'contrast differently',

    'compareByTable', 'compareByLine', 'unsupported mode',
    'Does not exist', 'match file header',

    'search pointer', 'parse table file', 'file comparison',

    'need to reselect process',
  },
  ['ru'] = {
    'Назад', 'Нет доступных цепей', 'Время выполнения', 'Выбрать вывод цепи',
    'Копировать смещение', 'Запустить', 'Вывести полный код', 'Файл таблицы:',

    'Файл проверки:', 'Не выбран элемент в списке сохранения',
    'Не найдены соответствующие заголовочные файлы. Пожалуйста, проверьте и измените правила соответствия заголовочных файлов.',
    'Глубина:', 'Смещение:', 'Ограничение на каждом уровне:', 'Сканировать до остановки:', 'Начальный адрес:',
    'Конечный адрес:', 'Выходной файл:', 'Вывести в файл таблицы', 'Вывести в файл проверки',
    'Выходной файл не выбран', 'Заголовочный файл не выбран',
    'Цепочки:', 'Время поиска:', 'Время вывода:',

    'Файл 1:', 'Файл 2:',

    'Сравнить по различиям',

    'Сравнить по таблице', 'Сравнить по строкам', 'Неподдерживаемый режим',
    'Не существует', 'Соответствовать заголовку файла',

    'Поиск указателя', 'Анализ файла', 'Сравнение файлов',
    'Необходимо выбрать процесс заново'

  },
  ['pt_BR'] = {
    'Voltar', 'Nenhuma cadeia disponível', 'Tempo gasto', 'Selecionar saída da cadeia',
    'Copiar deslocamentos', 'Executar', 'Gerar código completo', 'Arquivo de tabela:',

    'Arquivo de verificação:', 'Não selecionado na lista de salvamento',
    'Nenhum arquivo de cabeçalho correspondente encontrado. Verifique e modifique as regras de correspondência de arquivos de cabeçalho.',
    'Profundidade:', 'Deslocamento:', 'Limite por camada:', 'Pesquisar até parar:', 'Endereço inicial:',
    'Endereço final:', 'Arquivo de saída:', 'Gerar arquivo de tabela', 'Gerar arquivo de verificação',
    'Arquivo de saída não selecionado', 'Arquivo de cabeçalho não selecionado',
    'Cadeias:', 'Tempo de pesquisa:', 'Tempo de saída:',

    'Arquivo 1:', 'Arquivo 2:',

    'Contrastar diferentes',

    'Comparar por tabela', 'Comparar por linha', 'Modo não suportado',
    'Não existe', 'Corresponder ao cabeçalho do arquivo',

    'Pesquisar ponteiro', 'Analisar arquivo', 'Comparação de arquivos',
    'É necessário selecionar o processo novamente'

  },
  ['ar'] = {
    'العودة', 'لا توجد سلاسل متاحة', 'الوقت المستغرق', 'اختيار خرج السلسلة',
    'نسخ الإزاحة', 'تشغيل', 'إخراج كود كامل', 'ملف الجدول:',

    'ملف التحقق:', 'لم يتم تحديد عنصر في قائمة الحفظ',
    'لم يتم إيجاد ملفات رأس متطابقة. يرجى التحقق والتعديل على قواعد مطابقة ملفات الرأس.',

    'عمق:', 'إزاحة:', 'حد لكل مستوى:', 'الجساد حتى يتوقف:', 'عنوان البداية:',
    'عنوان النهاية:', 'ملف الإخراج:', 'إخراج في ملف الجدول', 'إخراج في ملف التحقق',

    'لم يتم تحديد ملف الإخراج', 'لم يتم تحديد ملف الرأس',
    'السلاسل:', 'وقت البحث:', 'وقت الإخراج:',

    'ملف 1:', 'ملف 2:',

    'مقارنة باختلاف',

    'مقارنة حسب الجدول', 'مقارنة حسب السطر', 'وضع غير مدعوم',
    'لا يوجد', 'تطابق رأس الملف',

    'بحث المؤشر', 'تحليل الملف', 'مقارنة الملفات',
    'يجب إعادة اختيار العملية'

  },
  ['uk'] = {
    'Назад', 'Немає доступних ланцюгів', 'Час виконання', 'Вибрати вивід ланцюга',
    'Копіювати зміщення', 'Запустити', 'Вивести повний код', 'Файл таблиці:',

    'Файл перевірки:', 'Не обрано елемент у списку збереження',
    'Не знайдено відповідних заголовних файлів. Будь ласка, перевірте та зміните правила відповідності заголовних файлів.',
    'Глибина:', 'Зміщення:', 'Обмеження на кожному рівні:', 'Сканувати до зупинки:', 'Початковий адреса:',
    'Кінцевий адреса:', 'Вихідний файл:', 'Вивести в файл таблиці', 'Вивести в файл перевірки',
    'Вихідний файл не обрано', 'Заголовний файл не обрано',
    'Ланцюги:', 'Час пошуку:', 'Час виводу:',

    'Файл 1:', 'Файл 2:',

    'Порівняти різниці',

    'Порівняти за таблицею', 'Порівняти за рядком', 'Непідтримуваний режим',
    'Не існує', 'Відповідає заголовку файлу',

    'Пошук вказівника', 'Розбір файлу', 'Порівняння файлів',
    'Необхідно знову вибрати процес'
  }
}

local setLocale = localeTable[gg.getLocale()] or localeTable['en_US']
local codeLocale = {
  back = setLocale[1],
  noChains = setLocale[2],
  time = setLocale[3],
  selectChainOut = setLocale[4],
  copyOffsets = setLocale[5],
  run = setLocale[6],
  outputFullCode = setLocale[7],
  tableFile = setLocale[8],
  fileValidation = setLocale[9],
  notSelectedInSaveLis = setLocale[10],
  noMatchHeader = setLocale[11],

  pointerDepth = setLocale[12],
  pointerOffset = setLocale[13],
  pointerLimitPerLayer = setLocale[14],
  scanToStop = setLocale[15],
  startAddress = setLocale[16],
  endAddress = setLocale[17],
  outputFilePath = setLocale[18],
  outputToTableFile = setLocale[19],
  outputToCheckFile = setLocale[20],

  outputFileNotSelected = setLocale[21],
  headerFileNotSelected = setLocale[22],

  chains = setLocale[23],
  searchTime = setLocale[24],
  outputTime = setLocale[25],

  file1 = setLocale[26],
  file2 = setLocale[27],

  contrastDifferently = setLocale[28],

  compareByTable = setLocale[29],
  compareByLine = setLocale[30],
  unsupportedMode = setLocale[31],

  doesNotExist = setLocale[32],
  matchFileHeader = setLocale[33],

  searchPointer = setLocale[34],
  parseFile = setLocale[35],
  fileComparison = setLocale[36],

  selectedProcess = setLocale[37]

}

local function tableContains(tbl, val)
  for _, value in pairs(tbl) do
    if value == val then
      return true
    end
  end
  return false
end

local function tableFindIndex(tbl, val)
  for index, value in pairs(tbl) do
    if value == val then
      return index
    end
  end
  return false
end

local function readFile(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local data = file:read("*a")
  file:close()
  return data
end

local function choice(options, title)
  local choices = {}
  local callbacks = {}
  for i = 1, #options, 2 do
    table.insert(choices, options[i])
    table.insert(callbacks, options[i + 1])
  end
  local input = gg.choice(choices, nil, title)
  if not input then
    return
  end
  callbacks[input]()
end

local function getTableString(tbl)
  return tostring(tbl):gsub('-- table%(.-%)', '')
end

local function getFunctionCode(funcNameTable)
  local file = io.open(gg.getFile(), 'r')
  if not file then return end
  local lines = {}
  for line in file:lines() do
    lines[#lines + 1] = line
  end
  file:close()
  local code = ''
  for _, funcName in ipairs(funcNameTable) do
    local info = debug.getinfo(funcName, 'S')
    for i = info.linedefined, info.lastlinedefined do
      code = code .. lines[i] .. '\n'
    end
    code = code .. '\n'
  end
  return code
end

local function getRangesList(matching, targetAddressState)
  local readableRanges = {}
  local interNameSet = {}

  for _, range in ipairs(gg.getRangesList(matching)) do
    local internalName = range.internalName:gsub('^.*/', ''):gsub(':bss$', '')
    interNameSet[internalName] = true
  end

  for internalName in pairs(interNameSet) do
    for rangeIndex, range in ipairs(gg.getRangesList(internalName)) do
      if range.type:sub(2, 2) == 'w' then
        if tableContains(staticHeaderState, targetAddressState) then
          if range.state == targetAddressState then
            range.internalName = '[' .. range.state .. ']' .. internalName .. '[' .. rangeIndex .. ']'
            table.insert(readableRanges, range)
            break
          end
         else
          for _, value in pairs(staticHeaderState) do
            if range.state == value then
              range.internalName = '[' .. range.state .. ']' .. internalName .. '[' .. rangeIndex .. ']'
              table.insert(readableRanges, range)
              break
            end
          end
        end
      end
    end
  end

  return readableRanges
end

local function searchPointerAddress(_is64Bit, soString, indexNum, offsetTable)
  local flags = _is64Bit and 32 or 4
  local padding = _is64Bit and 0xFFFFFFFFFFFFFFFF or 0xFFFFFFFF
  local address = gg.getRangesList(soString)[indexNum].start
  for i = 1, #offsetTable - 1 do
    local offset = tonumber(offsetTable[i])
    address = gg.getValues({ { address = offset + address, flags = flags } })[1].value & padding
  end
  address = address + offsetTable[#offsetTable]
  return string.format('0x%X', address)
end

local function outPathName(path, fileName)
  local outFilePath
  local outFileSerial = 0
  local folderPath = path:gsub('[^/]*$', '')
  fileName = fileName or path:match('.*/(.*)'):gsub('%d_', '')
  while true do
    outFileSerial = outFileSerial + 1
    outFilePath = string.format('%s%d_%s', folderPath, outFileSerial, fileName):gsub('%s+', '_')
    local file = io.open(outFilePath, 'r')
    if not file then
      break
     else
      file:close()
    end
  end
  return outFilePath
end

local function binarySearchLeftBoundary(arr, target)
  local left, right = 1, #arr
  local mid, ral
  while left <= right do
    mid = left + ((right - left) // 2)
    if arr[mid].address >= target then
      ral = mid
      right = mid - 1
     else
      left = mid + 1
    end
  end
  return ral
end

local function binarySearchRightBoundary(arr, target)
  local left, right = 1, #arr
  local mid, ral
  while left <= right do
    mid = left + ((right - left) // 2)
    if arr[mid].address <= target then
      ral = mid
      left = mid + 1
     else
      right = mid - 1
    end
  end
  return ral
end

local function generate(path)
  local function getSize(tableToCheck)
    if type(tableToCheck) ~= 'table' then
      return tableToCheck
    end

    for key, value in pairs(tableToCheck) do
      if type(value) == 'table' then
        if value.value == 1 then
          return true
        end
      end
      if getSize(value) then
        return true
      end
    end
    return false
  end

  local function navigate(results, pathDepth, backup, chain)
    if not pathDepth then
      pathDepth = 1
    end

    local navigationOptions = {}
    if pathDepth > 1 then
      navigationOptions[#navigationOptions + 1] = codeLocale.back
    end

    for key, value in pairs(results) do
      if getSize(value) then
        navigationOptions[#navigationOptions + 1] = key
      end
    end

    if #navigationOptions == 0 then
      print(codeLocale.noChains)
      return
    end

    local input = gg.choice(navigationOptions, true, table.concat(chain, ', '))
    if not input then
      return nil, pathDepth, backup, chain
    end
    if navigationOptions[input] == codeLocale.back then
      pathDepth = pathDepth - 1
      results = backup[pathDepth]
      chain[#chain] = nil
     else
      backup[pathDepth] = results
      results = results[navigationOptions[input]]
      table.insert(chain, navigationOptions[input])
      pathDepth = pathDepth + 1
    end
    return results, pathDepth, backup, chain
  end

  local file = io.open(path, 'r')
  if not file then
    return
   else
    file:close()
  end
  local results = dofile(path)
  if not results then return end
  local pathDepth
  local backup = {}
  local chain = {}
  while true do
    results, pathDepth, backup, chain = navigate(results, pathDepth, backup, chain)
    if not results or results == 1 then
      break
    end
  end
  if results == 1 then
    return chain
  end
end

local function loadChain(parametersTable)
  local lvl, parentData, rootRangeNameTable = parametersTable[1], parametersTable[2], parametersTable[3]
  local maxOffset, levelData, binarySearchFunc = parametersTable[4], parametersTable[5], parametersTable[6]
  local chainsRef, padding, chainResultsIimit = parametersTable[7], parametersTable[8], parametersTable[9]

  local nextFunc, _ipairs = next, ipairs
  local currentLevelData, nextLevelData
  local leftValue, rightValue, offset, value
  local indexAddress, indexValue
  local tempData = { address = nil, value = nil }
  local binaryProcessedData = false
  local rootRangeNameTableAddress = rootRangeNameTable.address
  local binarySearchFuncLeft, binarySearchFuncRight = binarySearchFunc.left, binarySearchFunc.right

  local shouldExit = false
  for _, parent in _ipairs(parentData) do
    rootRangeNameTable[parent.address - rootRangeNameTableAddress] = { value = parent.value }
  end

  rootRangeNameTable.address = nil
  local chainsCount = chainsRef.count or 0
  currentLevelData = rootRangeNameTable

  for currentLevel = lvl, 1, -1 do
    nextLevelData = {}
    local stopLoop = true
    local key = nextFunc(currentLevelData)

    while key do
      local valueData = currentLevelData[key]

      if valueData.address then
        valueData.address = nil
      end

      if valueData.value then
        value = valueData.value & padding
        valueData.value = nil

        for _, binaryRule in _ipairs(levelData[currentLevel]) do
          leftValue = binarySearchFuncLeft(binaryRule, value)
          rightValue = binarySearchFuncRight(binaryRule, value + maxOffset)

          if leftValue and rightValue then
            binaryProcessedData = true

            for index = leftValue, rightValue do
              indexAddress = binaryRule[index].address
              indexValue = binaryRule[index].value

              tempData = { address = indexAddress, value = indexValue }
              offset = tempData.address - value

              if currentLevel == 1 then
                valueData[offset] = 1
                chainsCount = chainsCount + 1
               else
                valueData[offset] = tempData
              end

              nextLevelData[#nextLevelData + 1] = tempData
              tempData, offset = { address = nil, value = nil }, nil
              indexAddress, indexValue = nil, nil

              if chainsCount == chainResultsIimit and chainResultsIimit ~= -1 and chainResultsIimit ~= 0 then
                shouldExit, stopLoop = true, true
                break
              end

              stopLoop = false
            end
           else
            if binaryProcessedData then
              break
            end
          end

          leftValue, rightValue = nil, nil

          if binaryProcessedData then
            binaryProcessedData = false
            break
          end
        end

        value = nil
       else
        currentLevelData[key] = nil
      end

      valueData = nil

      key = nextFunc(currentLevelData, key)
      if shouldExit then
        break
      end
    end

    if stopLoop or shouldExit then
      break
    end

    currentLevelData = nextLevelData
  end

  chainsRef.count = chainsCount
end

local function searchChains(parametersTable)
  local depth, readableRanges, root = parametersTable[1], parametersTable[2], parametersTable[3]
  local chainsRef, level, maxOffset = parametersTable[4], parametersTable[5], parametersTable[6]
  local limit, binarySearchFunc, padding = parametersTable[7], parametersTable[8], parametersTable[9]
  local chainResultsIimit, startAddress, endAddress = parametersTable[10], parametersTable[11], parametersTable[12]
  local targetAddressState = parametersTable[13]

  for lvl = 1, depth do
    if lvl == 1 and tableContains(staticHeaderState, targetAddressState) then
      local findStaticAddress = false
      for _, range in ipairs(readableRanges) do
        local results = gg.getResults(1, 0, range.start, range['end'])

        if #results == 1 then
          root[range.internalName] = { [results[1].address - range.start] = 1 }
          chainsRef.count = 1
          gg.removeResults(results)
          findStaticAddress = true
          break
        end
      end
      if not findStaticAddress then
        print(codeLocale.noMatchHeader)
      end
      break
    end

    level[lvl] = {}

    local skip, blockSize, blockIndex = 0, 8192, 1
    while true do
      local results = gg.getResults(blockSize, skip)

      if #results == 0 then
        break
      end
      skip = skip + blockSize
      level[lvl][blockIndex] = results
      blockIndex = blockIndex + 1
    end

    gg.searchPointer(maxOffset, startAddress, endAddress, limit)

    for _, range in ipairs(readableRanges) do
      local results = gg.getResults(gg.getResultsCount(), 0, range.start, range['end'])

      if #results > 0 then
        if not root[range.internalName] then
          root[range.internalName] = {}
        end
        if not root[range.internalName].address then
          root[range.internalName].address = range.start
        end
        gg.removeResults(results)
        if chainsRef.count == chainResultsIimit and chainResultsIimit ~= -1 and chainResultsIimit ~= 0 then
          break
        end
        local loadChainParametersTable = {
          lvl, results, root[range.internalName],
          maxOffset, level, binarySearchFunc,
          chainsRef, padding, chainResultsIimit,
        }
        loadChain(loadChainParametersTable)
      end
    end

    if gg.getResultsCount() == 0 or chainsRef.count == chainResultsIimit and chainResultsIimit ~= -1 and chainResultsIimit ~= 0 then
      break
    end
  end
end

local function getTargetAddressState(TargetAddress, strMatch)
  local rangesList, state = gg.getRangesList(strMatch)
  for index, range in ipairs(rangesList) do
    local startAddress, endAddress = range.start, range['end']
    if startAddress <= TargetAddress and TargetAddress <= endAddress then
      state = range.state
      break
    end
  end
  return state
end

local function parseTargetNumber(targetNumber)
  local selected = {}
  local remainingNumber = targetNumber
  while (remainingNumber ~= 0) do
    for index, integer in ipairs(RANGES_CODE) do
      if remainingNumber >= integer and remainingNumber ~= 0 then
        remainingNumber = remainingNumber - integer
        table.insert(selected, RANGES_SELECT[index])
      end
    end
  end
  return selected
end

local function contrastChain(tbl1, tbl2, tbl3, chainsNum, isSame)
  isSame.val = true
  local key
  key = next(tbl1)
  while key do
    local value = tbl1[key]
    local tbl2Val = tbl2[key]
    if tbl2Val == 1 then
      tbl3[key] = 1
      chainsNum.num = chainsNum.num + 1
     elseif type(tbl2Val) == 'table' then
      if type(value) ~= 'table' then
        isSame.val = false
       else
        tbl3[key] = {}
        contrastChain(value, tbl2Val, tbl3[key], chainsNum, isSame)
      end
     elseif value ~= tbl2Val then
      isSame.val = false
    end
    key = next(tbl1, key)
  end
  key = next(tbl2)
  while key do
    if tbl1[key] == nil then
      isSame.val = false
      break
    end
    key = next(tbl2, key)
  end
end

local function parseChainTable(chainsTable, _is64Bit)
  local headerTable = {}
  local contentTable = {}
  local flags = _is64Bit and 32 or 4
  local padding = _is64Bit and 0xFFFFFFFFFFFFFFFF or 0xFFFFFFFF

  for _, chain in pairs(chainsTable) do
    local chainId = chain[2]
    local subChainId = chain[3]

    if not headerTable[chainId] then
      headerTable[chainId] = {}
    end
    if not headerTable[chainId][subChainId] then
      headerTable[chainId][subChainId] = gg.getRangesList(chainId)[subChainId].start
    end

    local header = headerTable[chainId][subChainId]

    local chainOffsetTable = chain['offset']

    for i, offset in ipairs(chainOffsetTable) do
      if not contentTable[i] then
        contentTable[i] = {}
      end
      if i == 1 then
        local headerAddress = (#chainOffsetTable ~= 1) and
        (gg.getValues({ { address = header + offset, flags = flags } })[1].value & padding) or (header + offset)

        contentTable[i][#contentTable[i] + 1] = headerAddress
       else
        contentTable[i][#contentTable[i] + 1] = offset
      end
    end
  end

  local tempResultTable = {}

  for i = 1, #contentTable do
    local valueTable = contentTable[i]
    for j = 1, #valueTable do
      if i > 1 and i < #contentTable then
        local previousValue = (i == 2) and contentTable[1][j] or tempResultTable[j]
        local currentValue = valueTable[j]
        tempResultTable[j] = { address = currentValue + previousValue, flags = flags }
       elseif i == #contentTable then
        local previousResult = tempResultTable[j]
        local sumValue = previousResult and previousResult + valueTable[j] or valueTable[j]
        local resultAddress = string.format('0x%X', sumValue)
        if string.len(resultAddress) >= 10 then
          tempResultTable[j] = resultAddress
         else
          tempResultTable[j] = nil
        end
      end
    end

    if #tempResultTable > 0 and i ~= #contentTable then
      local getResults = gg.getValues(tempResultTable)
      local index
      index = next(getResults)
      while index do
        local value = getResults[index]
        tempResultTable[index] = value.value & padding
        index = next(getResults, index)
      end
    end
  end

  return (next(tempResultTable) and tempResultTable)
end

local function parseChains(targetFlags, _is64Bit, ContentTable)
  local selfPath = gg.getFile()
  local startTime = os.clock()

  local addressTable = parseChainTable(ContentTable, _is64Bit)

  if not addressTable then
    print(string.format(codeLocale.noChains .. '\n ' .. codeLocale.time .. ':%.2f', os.clock() - startTime))
    return
  end

  local storageAddresses, storedAddressValues = {}, {}
  local saveAddressPointerChain = {}
  for index, address in pairs(addressTable) do
    if not tableContains(storageAddresses, address) then
      table.insert(storageAddresses, address)
      storedAddressValues[address] = { address = address, flags = targetFlags }
    end
    if not saveAddressPointerChain[address] then
      saveAddressPointerChain[address] = {}
    end
    saveAddressPointerChain[address][index] = ContentTable[index]
  end

  storedAddressValues = gg.getValues(storedAddressValues)

  local showSelectTable = {}
  for index, address in pairs(storageAddresses) do
    showSelectTable[index] = address .. ' : ' .. storedAddressValues[address].value
  end

  if #showSelectTable == 0 then
    print(string.format(codeLocale.noChains .. '\n ' .. codeLocale.time .. ':%.2f', os.clock() - startTime))
    return
  end

  if #showSelectTable == 1 then
    local selectShowTable = {}

    for index, value in pairs(ContentTable) do
      selectShowTable[index] = string.format('[%d]: [%s]%s[%d] + %s', index, value[1], value[2], value[3],
      table.concat(value['offset'], ' -> '))
    end

    local choiceIndex = gg.choice(selectShowTable, nil,
    string.format(codeLocale.selectChainOut .. '(' .. codeLocale.time .. ':%.2f):', os.clock() - startTime))
    if not choiceIndex then return end

    local chain = ContentTable[choiceIndex]

    local outText = getFunctionCode({ searchPointerAddress }) ..
    '\n--searchPointerAddress([true 64bit | false 32bit], stringHeader, index, offsetTable)' ..
    '\n local address = searchPointerAddress(' ..
    tostring(_is64Bit) .. ', "' ..
    chain[2] .. '", ' ..
    chain[3] .. ', {' ..
    table.concat(chain['offset'], ', ') ..
    '}) \n\n gg.addListItems({{ address= address, flags = 4 , name = "Target Address" }})'

    local input = gg.alert(outText, codeLocale.copyOffsets, codeLocale.run, codeLocale.outputFullCode)
    if not input then return end

    if input == 1 then
      gg.copyText(table.concat(chain, ', ') .. ' + ' .. table.concat(chain['offset'], ' -> '), false)
     elseif input == 2 then
      load(outText)()
     elseif input == 3 then
      local path = outPathName(selfPath)
      local file = io.open(path, 'w+')
      if not file then return end
      file:write(outText)
      file:close()
      print(path)
    end
    return
  end

  local selectionResult = gg.multiChoice(showSelectTable, nil,
  string.format(codeLocale.selectChainOut .. '(' .. codeLocale.time .. ':%.2f):', os.clock() - startTime))
  if not selectionResult then return end

  local path = outPathName(selfPath)
  local file = io.open(path, 'w+')
  local uotputStartTime, outChainsNum = os.clock(), 0
  if not file then return end

  file:write(string.format(
  'local codeLocale = %s\n\n%s \n local targetFlags = %s\n local chainTable = {\n',
  getTableString(codeLocale),
  getFunctionCode({
    tableContains,
    getTableString,
    outPathName,
    getFunctionCode,
    searchPointerAddress,
    parseChainTable,
    parseChains
  }),
  targetFlags
  ))

  file:flush()
  local buffer = {}
  local bufferSize = 8192
  for index, isSelected in pairs(selectionResult) do
    if isSelected then
      local selectedAddress = storageAddresses[index]
      for chainIndex, chain in pairs(saveAddressPointerChain[selectedAddress]) do
        local chainInfo = string.format("[%d] = { '%s', '%s', %d, ['offset'] = { %s } },\n", chainIndex,
        chain[1], chain[2], chain[3], table.concat(chain['offset'], ', '))
        table.insert(buffer, chainInfo)
        if #buffer >= bufferSize then
          file:write(table.concat(buffer))
          outChainsNum = outChainsNum + #buffer
          buffer = {}
        end
      end
    end
  end

  if #buffer > 0 then
    file:write(table.concat(buffer))
    outChainsNum = outChainsNum + #buffer
  end
  file:write('}\n\n parseChains(targetFlags, ' .. tostring(gg.getTargetInfo().x64) .. ', chainTable) return\n')
  file:close()
  print(string.format('%s%s\n%s:%.2f %s%d', codeLocale.outputFilePath, path, codeLocale.time,
  os.clock() - uotputStartTime,
  codeLocale.chains, outChainsNum))
end

local function outputTableFile(root, path)
  gg.saveVariable(root, path)
  print(codeLocale.tableFile .. path)
end

local function chainsTableParse(tbl, path, outFile, chainsNum)
  local _next = next
  local _type = type
  local _match = string.match
  local _format = string.format
  local toStr = tostring
  local tblConcat = table.concat
  local tblInsert = table.insert
  local tblRemove = table.remove
  path = path or {}

  local key
  key = _next(tbl)
  while key do
    local value = tbl[key]
    tblInsert(path, toStr(key))
    if _type(value) == 'table' then
      chainsTableParse(value, path, outFile, chainsNum)
      tblRemove(path)
     elseif value == 1 then
      chainsNum.val = chainsNum.val + 1
      local header = path[1]
      local innerKey, outerKey, index = _match(header, '^%[(.-)%](.-)%[(%d+)%]$')
      local offsetParts = {}
      for i = 2, #path do
        offsetParts[i - 1] = offsetParts[i - 1] or ""
        offsetParts[i - 1] = path[i]
      end

      local offsetStr = tblConcat(offsetParts, ', ')
      local keyStr = _format("[%d] = { '%s', '%s', %d, ['offset'] = { %s } },\n",
      chainsNum.val, innerKey, outerKey, index, offsetStr)
      if outFile then outFile(keyStr) end
      tblRemove(path)
     else
      tblRemove(path)
    end

    key = _next(tbl, key)
  end
end

local function outputExecuTable(root, path, targetFlags)
  local uotFile = io.open(path, 'w+')
  if not uotFile then return end
  local chainsNum = { val = 0 }

  uotFile:write(string.format(
  'local codeLocale = %s\n\n%s \n local targetFlags = %s\n local chainTable = {\n',
  getTableString(codeLocale),
  getFunctionCode({
    tableContains,
    getTableString,
    outPathName,
    getFunctionCode,
    searchPointerAddress,
    parseChainTable,
    parseChains
  }),
  targetFlags
  ))

  uotFile:flush()
  local buffer = {}
  local function writeBuffer(uotFile)
    uotFile:write(table.concat(buffer))
    buffer = {}
  end

  chainsTableParse(root, {}, function(keyStr)
    table.insert(buffer, keyStr)
    if #buffer >= 8192 then
      writeBuffer(uotFile)
    end
  end, chainsNum)

  if #buffer > 0 then
    writeBuffer(uotFile)
  end

  uotFile:write('}\n\n parseChains(targetFlags, ' .. tostring(is64Bit) .. ', chainTable)  return \n')
  uotFile:close()
  print(codeLocale.fileValidation .. path .. ' ' .. codeLocale.chains .. chainsNum.val)
end

local function searchBaseAddress()
  local selectResults = gg.getSelectedListItems()
  if #selectResults ~= 1 then
    print(codeLocale.notSelectedInSaveLis)
    return
  end

  local targetResult = selectResults[1]
  local targetFlags = targetResult.flags
  local targetAddress = targetResult.address

  local targetAddressState = getTargetAddressState(targetAddress)
  if not targetAddressState then
    print(codeLocale.selectedProcess)
    return
  end

  local readableRanges = getRangesList('^/data/*lib*.so*$', targetAddressState)

  if #readableRanges == 0 then
    print(codeLocale.noMatchHeader)
    return
  end

  local prompValueName = {
    codeLocale.pointerDepth, 
    codeLocale.pointerOffset, 
    codeLocale.pointerLimitPerLayer, 

    codeLocale.scanToStop, 
    codeLocale.startAddress,
    codeLocale.endAddress, 

    codeLocale.outputFilePath, 
    codeLocale.outputToTableFile, 
    codeLocale.outputToCheckFile, 
  }

  for _, range in ipairs(readableRanges) do
    table.insert(prompValueName, range.internalName)
  end

  local promptPresetConfig = config[targetPackage]['promptPreset'] or
  { 3, 512, 0, 0, 0, -1, outPathName(filePath, targetProcessName .. '.lua'), true, true }

  local promptPreset = promptPresetConfig
  promptPreset[7] = promptPresetConfig and outPathName(filePath, targetProcessName .. '.lua') or promptPresetConfig[7]

  local prompValueType = { 'number', 'number', 'number', 'number', 'number', 'number', 'file', 'checkbox', 'checkbox' }

  for _, __ in ipairs(readableRanges) do
    table.insert(prompValueType, 'checkbox')
  end

  local promptResult = gg.prompt(prompValueName, promptPreset, prompValueType)
  if not promptResult then
    return
  end

  if not promptResult[8] and not promptResult[9] then
    gg.alert(codeLocale.outputFileNotSelected)
    searchBaseAddress()
    return
  end

  config[targetPackage]['promptPreset'] = promptResult

  local depth, maxOffset = tonumber(promptResult[1]), tonumber(promptResult[2])
  local limit, chainResultsIimit = tonumber(promptResult[3]), tonumber(promptResult[4])
  local startAddress, endAddress = tonumber(promptResult[5]), tonumber(promptResult[6])
  endAddress = (endAddress ~= 0 and endAddress ~= -1) and endAddress or -1

  local readableRangesFile = {}
  for index, bool in ipairs(promptResult) do
    if index > 9 and bool then
      table.insert(readableRangesFile, readableRanges[index - 9])
    end
  end

  if #readableRangesFile == 0 then
    gg.alert(codeLocale.headerFileNotSelected)
    searchBaseAddress()
    return
  end

  local rangesSize = RANGES_CODE[tableFindIndex(RANGES_SELECT, targetAddressState)]
  for _, range in ipairs(readableRangesFile) do
    local state = range.internalName:match('^%[(.-)%]')
    local containsState = tableContains(parseTargetNumber(rangesSize), state)
    local num = containsState and 0 or RANGES_CODE[tableFindIndex(RANGES_SELECT, state)]
    rangesSize = rangesSize + num
  end

  local originalRanges = gg.getRanges()
  local originalResults = gg.getResults(gg.getResultsCount())

  gg.saveVariable(config, configFilePath)
  gg.setRanges(rangesSize)

  gg.clearResults()
  gg.loadResults(selectResults)

  local level, root = {}, {}
  local binarySearch = { left = binarySearchLeftBoundary, right = binarySearchRightBoundary }
  local chainsRef, startTime = { count = 0 }, os.clock()

  local parameters = {
    depth, readableRangesFile, root,
    chainsRef, level, maxOffset,
    limit, binarySearch, paddingValue,
    chainResultsIimit, startAddress, endAddress,
    targetAddressState
  }

  searchChains(parameters)

  gg.clearResults()
  gg.setRanges(originalRanges)
  gg.loadResults(originalResults)

  local endTime = os.clock() - startTime

  local elapsedTime = string.format('\n' .. codeLocale.chains .. '%d\n' .. codeLocale.searchTime .. '%.2f',
  chainsRef.count, endTime)
  if chainsRef.count == 0 then
    print(elapsedTime)
    return
  end

  if promptResult[8] and promptResult[9] then
    outputTableFile(root, promptResult[7])
    outputExecuTable(root, outPathName(promptResult[7]), targetFlags)
   elseif promptResult[8] then
    outputTableFile(root, promptResult[7])
   elseif promptResult[9] then
    outputExecuTable(root, promptResult[7], targetFlags)
  end

  local outputTime = os.clock() - (endTime + startTime)
  print(elapsedTime .. string.format('\n' .. codeLocale.outputTime .. '%.2f', outputTime))
end

local function getChain(path)
  if not path then
    local promptResult = gg.prompt({ codeLocale.tableFile }, { filePath }, { 'file' })
    if not promptResult then return end
    local file = io.open(promptResult[1], 'r')
    if not file then return else file:close() end
    path = promptResult[1]
  end

  local chain = (generate(path))
  if not chain then return end

  local soName, index = string.match(chain[1], '^%[.-%](.-)%[(.-)%]$')
  local offsetTable = {}
  for i = 2, #chain do
    table.insert(offsetTable, chain[i])
  end

  local outText = getFunctionCode({ searchPointerAddress }) ..
  '\n--searchPointerAddress([true 64bit | false 32bit], stringHeader, index, offsetTable)' ..
  '\n local address = searchPointerAddress(' ..
  tostring(is64Bit) .. ', "' ..
  soName .. '", ' ..
  index .. ', {' ..
  table.concat(offsetTable, ', ') ..
  '}) \n\n gg.addListItems({{ address= address, flags = 4 , name = "targetAddress" }})'

  local input = gg.alert(outText, codeLocale.copyOffsets, codeLocale.run, codeLocale.outputFullCode)
  if not input then return end

  if input == 1 then
    gg.copyText(table.concat(chain, ', '), false)
   elseif input == 2 then
    load(outText)()
   elseif input == 3 then
    local outpath = outPathName(path)
    local outfile = io.open(outpath, 'w+')
    if not outfile then return end
    outfile:write(outText)
    outfile:close()
    print(outpath)
  end
end

local function combinedComparison(mode)
  local promptValue
  if mode == 'table' then
    promptValue = gg.prompt({ codeLocale.file1, codeLocale.file2, codeLocale.outputFilePath },
    { filePath, filePath, outPathName(filePath, codeLocale.compareByTable .. '.lua') },
    { 'file', 'file', 'file' })
   elseif mode == 'line' then
    promptValue = gg.prompt(
    { codeLocale.file1, codeLocale.file2, codeLocale.outputFilePath, codeLocale.contrastDifferently },
    { filePath, filePath, outPathName(filePath, codeLocale.compareByLine .. '.lua'), false },
    { 'file', 'file', 'file', 'checkbox' })
   else
    print(codeLocale.unsupportedMode)
    return
  end

  if not promptValue then return end

  local time, file1, file2, data, chainsNum, isSame

  file1 = io.open(promptValue[1], 'r')
  if not file1 then
    print(promptValue[1] .. codeLocale.doesNotExist)
    return
   else
    file1:close()
  end

  file2 = io.open(promptValue[2], 'r')
  if not file2 then
    print(promptValue[2] .. codeLocale.doesNotExist)
    return
   else
    file2:close()
  end

  if mode == "table" then
    time, file1, file2, data, chainsNum, isSame = os.clock(), dofile(promptValue[1]), dofile(promptValue[2]), {},
    { num = 0 }, { val = true }
    contrastChain(file1, file2, data, chainsNum, isSame)
    if isSame.val then
      getChain(promptValue[1])
      return
    end
    if chainsNum.num > 0 then
      gg.saveVariable(data, promptValue[3])
    end
    print(string.format(codeLocale.time .. ':%.2f\n' .. codeLocale.chains .. '%d\n %s', os.clock() - time,
    chainsNum.num,
    chainsNum.num > 0 and promptValue[3] or ''))
   elseif mode == "line" then
    time, file1, file2 = os.clock(), readFile(promptValue[1]), readFile(promptValue[2])
    if not file1 or not file2 then return end
    data = {}
    for v in file1:gmatch("(.-)\n") do
      data[v] = true
    end
    local file = io.open(promptValue[3], "w+")
    if not file then return end
    for v in file2:gmatch("(.-)\n") do
      if (data[v] and not promptValue[4]) or (not data[v] and promptValue[4]) then
        file:write(v .. "\n")
      end
    end
    file:close()
    print(string.format(codeLocale.time .. ':%.2f\n %s', os.clock() - time, promptValue[3]))
  end
end

local function fileComparisonTable()
  combinedComparison("table")
end

local function fileComparisonLine()
  combinedComparison("line")
end

local function fileComparisonMenu()
  choice({
    codeLocale.compareByTable, fileComparisonTable,
    codeLocale.compareByLine, fileComparisonLine,
    codeLocale.back, main,
  })
end

main = function()
  choice({
    codeLocale.searchPointer, searchBaseAddress,
    codeLocale.parseFile, getChain,
    codeLocale.fileComparison, fileComparisonMenu,
  })
end

xpcall(main, print)