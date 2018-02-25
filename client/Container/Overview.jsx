
import Actions from 'core/Actions';
import Component from 'core/Component';
import { connect } from 'react-redux';
import moment from 'moment';
import PropTypes from 'prop-types';
import React from 'react';

import CardText from 'component/Card/CardText';
import HorizontalRule from 'component/HorizontalRule';
import Table from 'component/Table';

class Overview extends Component {
  static propTypes = {
    getLatest: PropTypes.func.isRequired,
    txs: PropTypes.array.isRequired
  };

  constructor(props) {
    super(props);

    this.state = {
      cols: [
        'height',
        {title: 'Transaction Hash', key: 'hash'},
        'age',
        'amount',
        'recipients',
        'time'],
      limit: 10
    };
  };

  componentDidMount() {
    this.props
      .getLatest({ limit: this.state.limit })
      .then(this.getLatest)
      .catch(this.getLatest);
  };

  componentWillUnmount() {
    if (this.timeout) {
      clearTimeout(this.timeout);
      this.timeout = null;
    }
  };

  getLatest = () => {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }

    this.timeout = setTimeout(() => {
      this.props
        .getLatest({ limit: this.state.limit })
        .then(this.getLatest)
        .catch(this.getLatest);
    }, 30000); // 30 seconds
  };

  render() {
    // Setup the list of transactions with age since created.
    const txs = this.props.txs.map(tx => ({
      ...tx,
      age: moment(tx.createdAt).fromNow()
    }));

    return (
      <div>
        <h1>Overview</h1>
        <CardText title="LALALA" />
        <HorizontalRule title="Latest Blocks" />
        <Table
          cols={ this.state.cols }
          data={ txs } />
      </div>
    );
  };
}

const mapDispatch = dispatch => ({
  getLatest: query => Actions.getTXLatest(dispatch, query)
});

const mapState = state => ({
  txs: state.txs
});

export default connect(mapState, mapDispatch)(Overview);
