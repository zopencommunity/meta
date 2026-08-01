import DefaultTheme from 'vitepress/theme'
import './custom.css'
import type { Theme } from 'vitepress'
import ToolFilters from './components/ToolFilters.vue'

// Carbon Icons – register commonly used icons globally (20px size)
// Full list: https://carbondesignsystem.com/elements/icons/library/
import {
  Home20,
  Rocket20,
  Tools20,
  ToolKit20,
  ProductionService20,
  IbmWatsonMachineLearning20,
  UserCertification20,
  ChatBot20,
  Education20,
  CloudDownload20,
  Notebook20,
  UserMultiple20,
  Star20,
  Flag20,
  Information20,
  Terminal20,
  Earth20,
  BookmarkFilled20,
  User20,
  Trophy20,
  CheckmarkFilled20,
  CheckmarkOutline20,
  List20,
  ListBulleted20,
  ChevronDown20,
  ChevronRight20,
  ChevronUp20,
  ArrowRight20,
  ArrowLeft20,
  Search20,
  Edit20,
  Add20,
  Close20,
  Warning20,
  ErrorFilled20,
  Link20,
  Document20,
  Folder20,
  FolderOpen20,
  Code20,
  Package20,
  Settings20,
  OverflowMenuVertical20,
  Download20,
  Upload20,
  Launch20,
  Tag20,
  Filter20,
  Copy20,
  Reset20,
} from '@carbon/icons-vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    // Register global components
    app.component('ToolFilters', ToolFilters)

    // Register Carbon icons as global Vue components (20px size)
    app.component('CarbonHome', Home20)
    app.component('CarbonRocket', Rocket20)
    app.component('CarbonTools', Tools20)
    app.component('CarbonToolKit', ToolKit20)
    app.component('CarbonProductionService', ProductionService20)
    app.component('CarbonIbmWatsonMachineLearning', IbmWatsonMachineLearning20)
    app.component('CarbonUserCertification', UserCertification20)
    app.component('CarbonChatBot', ChatBot20)
    app.component('CarbonEducation', Education20)
    app.component('CarbonCloudDownload', CloudDownload20)
    app.component('CarbonNotebook', Notebook20)
    app.component('CarbonUserMultiple', UserMultiple20)
    app.component('CarbonStar', Star20)
    app.component('CarbonFlag', Flag20)
    app.component('CarbonInformation', Information20)
    app.component('CarbonTerminal', Terminal20)
    app.component('CarbonEarth', Earth20)
    app.component('CarbonBookmark', BookmarkFilled20)
    app.component('CarbonUser', User20)
    app.component('CarbonTrophy', Trophy20)
    app.component('CarbonCheckmark', CheckmarkFilled20)
    app.component('CarbonCheckmarkOutline', CheckmarkOutline20)
    app.component('CarbonList', List20)
    app.component('CarbonListBulleted', ListBulleted20)
    app.component('CarbonChevronDown', ChevronDown20)
    app.component('CarbonChevronRight', ChevronRight20)
    app.component('CarbonChevronUp', ChevronUp20)
    app.component('CarbonArrowRight', ArrowRight20)
    app.component('CarbonArrowLeft', ArrowLeft20)
    app.component('CarbonSearch', Search20)
    app.component('CarbonEdit', Edit20)
    app.component('CarbonAdd', Add20)
    app.component('CarbonClose', Close20)
    app.component('CarbonWarning', Warning20)
    app.component('CarbonError', ErrorFilled20)
    app.component('CarbonLink', Link20)
    app.component('CarbonDocument', Document20)
    app.component('CarbonFolder', Folder20)
    app.component('CarbonFolderOpen', FolderOpen20)
    app.component('CarbonCode', Code20)
    app.component('CarbonPackage', Package20)
    app.component('CarbonSettings', Settings20)
    app.component('CarbonOverflow', OverflowMenuVertical20)
    app.component('CarbonDownload', Download20)
    app.component('CarbonUpload', Upload20)
    app.component('CarbonLaunch', Launch20)
    app.component('CarbonTag', Tag20)
    app.component('CarbonFilter', Filter20)
    app.component('CarbonCopy', Copy20)
    app.component('CarbonReset', Reset20)
  }
} satisfies Theme

// Made with Bob
