import Component from '../core/Component';
import {connect} from 'react-redux';
import PropTypes from 'prop-types';
import React from 'react';
import moment from 'moment';

import Icon from './Icon';

/**
 * Will use material icons to render.
 * @param {Object} props The props with the name.
 */
class Footer extends Component {
    static propTypes = {
        coins: PropTypes.array.isRequired,
        txs: PropTypes.array.isRequired,
    };
    render() {
        const coin = this.props.coins && this.props.coins.length ? this.props.coins[0] : {status: 'offline', blocks: 0};
        const blocks = this.props.txs && this.props.txs.length ? this.props.txs[0].blockHeight : coin.blocks;
        const statusColor = (coin.status && coin.status.toLowerCase() === 'online') ? 'green' : 'red';

        return (
            <div className="footer">
                <div className="footer__block">
                    <img className="footer__logo" src="/img/footerlogo.png"/>
                    <span className="footer__legal">
                        <div>Copyright &copy; 2019 <a href="https://adultchain.me/">Adultchain</a></div>
                        <div>Forked from <a href="https://bulwarkcrypto.com/">Bulwark Cryptocurrency</a> <a href="https://github.com/bulwark-crypto/bulwark-explorer">explorer</a>.</div>
                    </span>
                </div>
                <div className="footer__block">
                    <div className="footer__data-wrapper">
                        <div className="footer__data-block">
                            <p className="footer__data-title">Status</p>
                            <p>
                                <span className={`u__dot u--text-${statusColor}`}>&bull;</span>
                                <span>{coin.status}</span>
                            </p>
                        </div>
                        <div className="footer__data-block">
                            <p className="footer__data-title">Blocks</p>
                            <p><b>{blocks}</b></p>
                        </div>
                        <div className="footer__data-block">
                            <p className="footer__data-title">Time</p>
                            <p>{`${moment().utc().format('HH:mm')}  UTC`}</p>
                        </div>
                    </div>
                </div>
                <div className="footer__block">
                    <div className="footer__social-media-wrapper">
                        <div className="footer__social-title">Social Media</div>
                        <div>
                            <a href="https://bitcointalk.org/index.php?topic=3296722.0" target="_blank">
                                <Icon name="bitcoin" className="fab footer__social-media-icon" />
                            </a>
                            <a href="https://discord.gg/a7vhegP" target="_blank">
                                <Icon name="discord" className="fab footer__social-media-icon"/>
                            </a>
                            <a href="https://www.reddit.com/r/adultchain/" target="_blank">
                                <Icon name="reddit" className="fab footer__social-media-icon"/>
                            </a>
                            <a href="https://github.com/AdultChain" target="_blank">
                                <Icon name="github" className="fab footer__social-media-icon"/>
                            </a>
                            <a href="https://twitter.com/adultchainxxx" target="_blank">
                                <Icon name="twitter" className="fab footer__social-media-icon"/>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        );
    };
};

const mapState = state => ({
    coins: state.coins,
    txs: state.txs,
});

export default connect(mapState)(Footer);