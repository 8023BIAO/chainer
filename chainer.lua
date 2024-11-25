local type = type
local load = load
local next = next
local pairs = pairs
local print = print
local table = table
local dofile = dofile
local ipairs = ipairs
local string = string
local xpcall = xpcall
local tostring = tostring
local tonumber = tonumber
local loadfile = loadfile
local debug = { getinfo = debug.getinfo }
local os = { clock = os.clock, remove = os.remove }
local io = { open = io.open, write = io.write, close = io.close, flush = io.flush, lines = io.lines }

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

local rangesCode = {
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

local rangesState = {
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

local staticHeaderState = { 'Cd', 'Cb', 'Xa', 'PS', 'Xa', 'O' }

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

  chainsCount = setLocale[23],
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
  return tostring(tbl):gsub('%-%- table%(.-%)', '')
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

local function getRangesList(internalNamePattern, targetAddress)
  local targetAddressState
  local targetAddressStaticState
  local findTargetAddressStaticState
  local readableRanges = {}
  local uniqueInternalNameSet = {}
  local internalNameToRangesMap = {}
  local rangesList = gg.getRangesList()

  for _, range in ipairs(rangesList) do
    if not targetAddressState then
      if range.start <= targetAddress and targetAddress <= range['end'] then
        targetAddressState = range.state
      end
    end

    local internalNameMatch = range.internalName:match(internalNamePattern)

    if internalNameMatch then
      local internalName = range.internalName:gsub('^.*/', ''):gsub(':bss$', '')
      uniqueInternalNameSet[internalName] = true
      if not internalNameToRangesMap[internalName] then
        internalNameToRangesMap[internalName] = {}
      end
      table.insert(internalNameToRangesMap[internalName], range)
    end
  end

  if not targetAddressState then
    print(codeLocale.selectedProcess)
    return false, false
  end

  targetAddressStaticState = tableContains(staticHeaderState, targetAddressState)

  for internalName in pairs(uniqueInternalNameSet) do
    for rangeIndex, range in ipairs(internalNameToRangesMap[internalName]) do
      local readabilityRange = (range.type:sub(2, 2) == 'w')
      local staticState = tableContains(staticHeaderState, range.state)

      if readabilityRange and staticState then
        range.internalName = string.format('[%s]%s[%d]', range.state, internalName, rangeIndex)

        if targetAddressStaticState and targetAddressState == range.state and range.start <= targetAddress and targetAddress <= range['end'] then
          readableRanges = { range }
          findTargetAddressStaticState = true
          break
        else
          table.insert(readableRanges, range)
        end
      end
    end
    if targetAddressStaticState and findTargetAddressStaticState then
      break
    end
  end

  if #readableRanges == 0 then
    print(codeLocale.noMatchHeader)
    return false, false
  end

  table.sort(readableRanges, function(a, b)
    return #a.internalName < #b.internalName
  end)

  return readableRanges, targetAddressState, targetAddressStaticState and findTargetAddressStaticState and true or false
end

local function searchPointerAddress(_is64Bit, soString, indexNum, offsetTable)
  local offset
  local flags = _is64Bit and 32 or 4
  local padding = _is64Bit and 0xFFFFFFFFFFFFFFFF or 0xFFFFFFFF
  local address = gg.getRangesList(soString)[indexNum].start
  for i = 1, #offsetTable - 1 do
    offset = tonumber(offsetTable[i])
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
  if not file then return else file:close() end

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

  local _next, _ipairs = next, ipairs
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
    local key = _next(currentLevelData)

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

      key = _next(currentLevelData, key)
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

  for lvl = 1, depth do
    level[lvl] = {}

    local skip, blockSize, blockIndex = 0, 100000, 1
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
        local loadChainParametersTable = {
          lvl, results, root[range.internalName],
          maxOffset, level, binarySearchFunc,
          chainsRef, padding, chainResultsIimit,
        }
        loadChain(loadChainParametersTable)
        if chainsRef.count == chainResultsIimit and chainResultsIimit ~= -1 and chainResultsIimit ~= 0 then
          break
        end
      end
    end

    if gg.getResultsCount() == 0 or chainsRef.count == chainResultsIimit and chainResultsIimit ~= -1 and chainResultsIimit ~= 0 then
      break
    end
  end
end

local function parseTargetNumber(targetNumber)
  local selected = {}
  local remainingNumber = targetNumber
  while (remainingNumber ~= 0) do
    for index, integer in ipairs(rangesCode) do
      if remainingNumber >= integer and remainingNumber ~= 0 then
        remainingNumber = remainingNumber - integer
        table.insert(selected, rangesState[index])
      end
    end
  end
  return selected
end

local function contrastChain(tbl1, tbl2, tbl3, chainsCount, isSame)
  isSame.val = true
  local key
  key = next(tbl1)
  while key do
    local value = tbl1[key]
    local tbl2Val = tbl2[key]
    if tbl2Val == 1 then
      tbl3[key] = 1
      chainsCount.val = chainsCount.val + 1
    elseif type(tbl2Val) == 'table' then
      if type(value) ~= 'table' then
        isSame.val = false
      else
        tbl3[key] = {}
        contrastChain(value, tbl2Val, tbl3[key], chainsCount, isSame)
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

  for chainIndex, chain in pairs(chainsTable) do
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

    for offsetIndex, offset in ipairs(chainOffsetTable) do
      if not contentTable[chainIndex] then
        contentTable[chainIndex] = {}
      end
      if offsetIndex == 1 then
        local hwaderOffset = gg.getValues({ { address = header + offset, flags = flags } })[1].value & padding
        local headerAddress = (#chainOffsetTable ~= 1) and hwaderOffset or (header + offset)
        contentTable[chainIndex][#contentTable[chainIndex] + 1] = headerAddress
      else
        contentTable[chainIndex][#contentTable[chainIndex] + 1] = offset
      end
    end
  end

  local tempResultTable = {}

  local offsetIndex = 1
  local offsetTableCount
  local chainIndex, offsetTable
  chainIndex, offsetTable = next(contentTable)
  offsetTableCount = #offsetTable

  while true do
    if chainIndex then
      if offsetIndex > 1 and offsetIndex < offsetTableCount then
        local previousValue = (offsetIndex == 2) and contentTable[chainIndex][1] or tempResultTable[chainIndex]
        local currentValue = contentTable[chainIndex][offsetIndex]
        tempResultTable[chainIndex] = { address = currentValue + previousValue, flags = flags }
      elseif offsetIndex == offsetTableCount then
        local sumValue = tempResultTable[chainIndex] + offsetTable[offsetTableCount]
        local resultAddress = string.format('0x%X', sumValue)
        if string.len(resultAddress) >= 10 and string.len(resultAddress) <= 18 or string.sub(3, 4) == 'b4' then
          tempResultTable[chainIndex] = resultAddress
        else
          tempResultTable[chainIndex] = nil
        end
      end
    end

    chainIndex, offsetTable = next(contentTable, chainIndex)
    if not chainIndex then
      if next(tempResultTable) and offsetIndex < offsetTableCount then
        local getResults = gg.getValues(tempResultTable)
        local index = next(getResults)
        while index do
          local value
          value = getResults[index]
          tempResultTable[index] = value.value & padding
          index = next(getResults, index)
        end
      end
      offsetIndex = offsetIndex + 1
      if offsetIndex <= offsetTableCount then
        chainIndex, offsetTable = next(contentTable)
        offsetTableCount = #offsetTable
      else
        break
      end
    end
  end

  return (next(tempResultTable) and tempResultTable)
end

local function outLoadChainerText(_is64Bit, soName, index, offsetTable, _targetPackage)
  local outText = 'local gg = require \'gg\'\n' ..
      'local selectTargetPackage = gg.getTargetPackage()\nlocal targetPackage = \'' .. _targetPackage .. '\'\n\n' ..
      'if selectTargetPackage ~= targetPackage then\n  print(\'targetPackage: \' .. targetPackage)\n  return\nend\n\n' ..
      getFunctionCode({ searchPointerAddress }) ..
      '--searchPointerAddress([true 64bit | false 32bit], stringHeader, index, offsetTable)' ..
      '\nlocal address = searchPointerAddress(' ..
      tostring(_is64Bit) .. ', "' ..
      soName .. '", ' ..
      index .. ', {' ..
      table.concat(offsetTable, ', ') ..
      '}) \n\ngg.addListItems({{ address= address, flags = 4 , name = "Target Address" }})'
  return outText
end

local function uotCopyFuncText(file, targetFlags, func, _targetPackage)
  if not file then return end
  file:write(string.format(
    'local gg = require \'gg\'\n%s\nlocal codeLocale = %s\n\n%slocal targetFlags = %s\nlocal chainTable = {\n',
    'local selectTargetPackage = gg.getTargetPackage()\nlocal targetPackage = \'' .. _targetPackage .. '\'\n\n' ..
    'if selectTargetPackage ~= targetPackage then\n  print(\'targetPackage: \' .. targetPackage)\n  return\nend\n',
    getTableString(codeLocale),
    getFunctionCode({
      tableContains,
      getTableString,
      outPathName,
      getFunctionCode,
      searchPointerAddress,
      parseChainTable,
      outLoadChainerText,
      uotCopyFuncText,
      func
    }),
    targetFlags
  ))
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
      local pointersOffset = {}
      local offset = value['offset']
      local offsetNum = #offset
      table.move(offset, 1, offsetNum - 1, 1, pointersOffset)
      local showString = string.format('[%d]: [%s]%s[%d] + %s', index, value[1], value[2], value[3],
        table.concat(pointersOffset, ' -> ') .. ' + ' .. offset[offsetNum])
      selectShowTable[index] = showString
    end

    local choiceIndex = gg.choice(selectShowTable, nil,
      string.format(codeLocale.selectChainOut .. '(' .. codeLocale.time .. ':%.2f):', os.clock() - startTime))
    if not choiceIndex then return end

    local chain = ContentTable[choiceIndex]

    local outText = outLoadChainerText(_is64Bit, chain[2], chain[3], chain['offset'], gg.getTargetPackage())

    local input = gg.alert(outText, codeLocale.copyOffsets, codeLocale.run, codeLocale.outputFullCode)
    if not input then return end

    if input == 1 then
      local otherOffsets = {}
      local offsetArray = chain['offset']
      local offsetCount = #offsetArray
      table.move(offsetArray, 1, offsetCount - 1, 1, otherOffsets)
      local copiedText = string.format('[%s]%s[%d] + %s', chain[1], chain[2], chain[3],
        table.concat(otherOffsets, ' -> ') .. ' + ' .. offsetArray[offsetCount])
      gg.copyText(copiedText, false)
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
  local uotputStartTime, outChainsCount = os.clock(), 0
  if not file then return end

  uotCopyFuncText(file, targetFlags, parseChains, gg.getTargetPackage())

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
          outChainsCount = outChainsCount + #buffer
          buffer = {}
        end
      end
    end
  end

  if #buffer > 0 then
    file:write(table.concat(buffer))
    outChainsCount = outChainsCount + #buffer
  end

  file:write('}\n\nxpcall(function() parseChains(targetFlags, ' ..
    tostring(gg.getTargetInfo().x64) .. ', chainTable) end, print)\nreturn\n')

  file:close()

  if outChainsCount == 0 then
    os.remove(path)
  end

  print(string.format('%s%s\n%s:%.2f %s%d',
    codeLocale.outputFilePath,
    path,
    codeLocale.time,
    os.clock() - uotputStartTime,
    codeLocale.chainsCount,
    outChainsCount
  ))
end

local function outputTableFile(root, path)
  gg.saveVariable(root, path)
  print(codeLocale.tableFile .. path)
end

local function chainsTableParse(tbl, path, outFile, chainsCount)
  local _next = next
  local _type = type
  local _match = string.match
  local _format = string.format
  local _tostring = tostring
  local tblConcat = table.concat
  local tblInsert = table.insert
  local tblRemove = table.remove
  path = path or {}

  local key
  key = _next(tbl)
  while key do
    local value = tbl[key]
    tblInsert(path, _tostring(key))
    if _type(value) == 'table' then
      chainsTableParse(value, path, outFile, chainsCount)
      tblRemove(path)
    elseif value == 1 then
      chainsCount.val = chainsCount.val + 1
      local header = path[1]
      local innerKey, outerKey, index = _match(header, '^%[(.-)%](.-)%[(%d+)%]$')
      local offsetParts = {}

      for i = 2, #path do
        offsetParts[i - 1] = offsetParts[i - 1] or ""
        offsetParts[i - 1] = path[i]
      end

      local offsetStr = tblConcat(offsetParts, ', ')
      local keyStr = _format("[%d] = { '%s', '%s', %d, ['offset'] = { %s } },\n",
        chainsCount.val, innerKey, outerKey, index, offsetStr)
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
  local chainsCount = { val = 0 }

  uotCopyFuncText(uotFile, targetFlags, parseChains, targetPackage)

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
  end, chainsCount)

  if #buffer > 0 then
    writeBuffer(uotFile)
  end

  uotFile:write('}\n\nxpcall(function() parseChains(targetFlags, ' ..
    tostring(is64Bit) .. ', chainTable) end, print)\nreturn\n')

  uotFile:close()

  print(codeLocale.fileValidation .. path .. ' ' .. codeLocale.chainsCount .. chainsCount.val)
end

local function searchBaseAddress()
  local selectResults = gg.getSelectedListItems()
  if #selectResults ~= 1 then
    print(codeLocale.notSelectedInSaveLis)
    return
  end

  local internalNamePatternMatch = '/data/.-%.so'

  local targetResult = selectResults[1]
  local targetFlags = targetResult.flags
  local targetAddress = targetResult.address

  local readableRanges, targetAddressState, targetAddressStaticState = getRangesList(internalNamePatternMatch,
    targetAddress)

  if not readableRanges or not targetAddressState then return end

  local targetAddressStateNumber = rangesCode[tableFindIndex(rangesState, targetAddressState)]

  local originalRanges = gg.getRanges()
  local originalResults = gg.getResults(gg.getResultsCount())

  if targetAddressStaticState then
    local soName, index, offset

    gg.clearResults()
    gg.setRanges(targetAddressStateNumber)
    gg.loadResults(selectResults)

    local range = readableRanges[1]
    local results = gg.getResults(1, 0, range.start, range['end'])
    soName, index = string.match(range.internalName, '^%[.-%](.-)%[(.-)%]$')
    offset = results[1].address - range.start

    gg.removeResults(results)
    gg.setRanges(originalRanges)
    gg.loadResults(originalResults)

    local uotPath = outPathName(filePath, targetProcessName .. '.lua')
    local outFile = io.open(uotPath, 'w+')
    if not outFile then return end
    outFile:write(outLoadChainerText(is64Bit, soName, index, { offset }, targetPackage))
    outFile:close()
    print(uotPath)
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
      { 3, 1024, 0, 0, 0, -1, outPathName(filePath, targetProcessName .. '.lua'), true, true }

  local promptPreset = promptPresetConfig
  promptPreset[7] = promptPresetConfig and outPathName(filePath, targetProcessName .. '.lua') or promptPresetConfig[7]

  local prompValueType = { 'number', 'number', 'number', 'number', 'number', 'number', 'file', 'checkbox', 'checkbox' }

  for _, __ in ipairs(readableRanges) do
    table.insert(prompValueType, 'checkbox')
  end

  local promptResult = gg.prompt(prompValueName, promptPreset, prompValueType)
  if not promptResult then return end

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

  local rangesSize = targetAddressStateNumber

  for _, range in ipairs(readableRangesFile) do
    local state = range.internalName:match('^%[(.-)%]')
    local containsState = tableContains(parseTargetNumber(rangesSize), state)
    local stateNum = containsState and 0 or rangesCode[tableFindIndex(rangesState, state)]
    rangesSize = rangesSize + stateNum
  end

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
  }

  searchChains(parameters)

  gg.clearResults()
  gg.setRanges(originalRanges)
  gg.loadResults(originalResults)

  local endTime = os.clock() - startTime

  local elapsedTime = string.format('\n' .. codeLocale.chainsCount .. '%d\n' .. codeLocale.searchTime .. '%.2f',
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
    if not file then
      return
    else
      file:close()
    end
    path = promptResult[1]
  end

  local chain = (generate(path))
  if not chain then return end

  local soName, index = string.match(chain[1], '^%[.-%](.-)%[(.-)%]$')
  local offsetTable = {}
  for i = 2, #chain do
    table.insert(offsetTable, chain[i])
  end

  local outText = outLoadChainerText(is64Bit, soName, index, offsetTable, targetPackage)

  local input = gg.alert(outText, codeLocale.copyOffsets, codeLocale.run, codeLocale.outputFullCode)
  if not input then return end

  if input == 1 then
    local pointersOffset = {}
    local offsetCount = #chain
    table.move(chain, 2, offsetCount - 1, 1, pointersOffset)
    local copyText = string.format('%s + %s', chain[1],
      table.concat(pointersOffset, ' -> ') .. ' + ' .. chain[offsetCount])
    gg.copyText(copyText, false)
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

  local promptValueName = { codeLocale.file1, codeLocale.file2, codeLocale.outputFilePath }
  local promptValuePreset = { filePath, filePath }
  local promptValueType = { 'file', 'file', 'file' }

  if mode == 'table' then
    table.insert(promptValuePreset, outPathName(filePath, codeLocale.compareByTable .. '.lua'))
  elseif mode == 'line' then
    table.insert(promptValueName, codeLocale.contrastDifferently)
    table.insert(promptValuePreset, outPathName(filePath, codeLocale.compareByLine .. '.lua'))
    table.insert(promptValueType, 'checkbox')
  else
    print(codeLocale.unsupportedMode)
    return
  end

  promptValue = gg.prompt(promptValueName, promptValuePreset, promptValueType)

  if not promptValue then return end

  local time, file1, file2, data, chainsCount, isSame

  file1 = io.open(promptValue[1], 'r')
  if not file1 then
    print(promptValue[1] .. codeLocale.doesNotExist)
    return
  end

  if mode ~= 'line' then
    file1:close()
  end

  file2 = io.open(promptValue[2], 'r')
  if not file2 then
    if mode == 'line' then
      file1:close()
    end
    print(promptValue[2] .. codeLocale.doesNotExist)
    return
  end

  if mode ~= 'line' then
    file2:close()
  end
  if mode == "table" then
    time, file1, file2, data, chainsCount, isSame = os.clock(), dofile(promptValue[1]), dofile(promptValue[2]), {},
        { val = 0 }, { val = true }
    contrastChain(file1, file2, data, chainsCount, isSame)
    if isSame.val then
      getChain(promptValue[1])
      return
    end
    if chainsCount.val > 0 then
      gg.saveVariable(data, promptValue[3])
    end
    print(string.format(codeLocale.time .. ':%.2f\n' .. codeLocale.chainsCount .. '%d\n %s',
      os.clock() - time,
      chainsCount.val,
      chainsCount.val > 0 and promptValue[3] or ''))
  elseif mode == "line" then
    time, data = os.clock(), {}
    for line in file1:lines() do
      data[line] = true
    end
    file1:close()
    local outfile = io.open(promptValue[3], "w+")
    if not outfile then return end
    for line in file2:lines() do
      if (data[line] and not promptValue[4]) or (not data[line] and promptValue[4]) then
        outfile:write(line .. "\n")
      end
    end
    file2:close()
    outfile:close()
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
