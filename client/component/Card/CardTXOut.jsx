
import Component from '../../core/Component';
import { Link } from 'react-router-dom';
import moment from 'moment';
import numeral from 'numeral';
import PropTypes from 'prop-types';
import React from 'react';

import Table from '../Table';

import config from '../../../config.js';
const ticker = `${config.project.ticker}`;


export default class CardTXOut extends Component {
  static defaultProps = {
    txs: []
  };

  static propTypes = {
    txs: PropTypes.array.isRequired
  };

  constructor(props) {
    super(props);
    this.state = {
      cols: [
        { key: 'address', title: 'Address' },
        { key: 'value', title: 'Amount' }
      ]
    };
  };

  render() {
    return (
      <Table
        cols={ this.state.cols }
        data={ this.props.txs.map(tx => ({
          ...tx,
          address: (
            <Link to={ `/address/${ tx.address }` }>{ tx.address }</Link>
          ),
          value: (
            <span className="badge badge-success">
              { numeral(tx.value).format('0,0.0000') } {ticker}
            </span>
          )
        })) } />
    );
  };
}
