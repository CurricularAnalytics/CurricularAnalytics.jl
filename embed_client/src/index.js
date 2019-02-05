// This file will build the plugin

import Curriculum from './components/Curriculum'
import { default as BaseCurriculum } from './base/Curriculum'
import { default as BaseTerm } from './base/Term'
import { default as BaseItem } from './base/Item'
import { default as BaseLink } from './base/Link'

import buildCurriculum from './helpers/buildCurriculum'
import formatCurriculum from './helpers/formatCurriculum'
import validateCurriculum from './helpers/validateCurriculum'

import './assets/styles/plugin.scss'

export default Curriculum

export { validateCurriculum, formatCurriculum, buildCurriculum, Curriculum, BaseCurriculum, BaseTerm, BaseItem, BaseLink }
